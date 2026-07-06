package com.vertical.bookings.service

import com.fasterxml.jackson.databind.ObjectMapper
import com.vertical.bookings.dto.BookingDto
import com.vertical.bookings.dto.BookingListResponse
import com.vertical.bookings.dto.BookingSummaryDto
import com.vertical.bookings.dto.CreateBookingRequest
import com.vertical.bookings.dto.CreateBookingResponse
import com.vertical.bookings.entity.BookingEntity
import com.vertical.bookings.entity.IdempotencyKeyEntity
import com.vertical.bookings.repository.BookingRepository
import com.vertical.bookings.repository.BookingSpecifications
import com.vertical.bookings.repository.IdempotencyKeyRepository
import com.vertical.bookings.support.BookingRequestHasher
import com.vertical.common.exception.BadRequestException
import com.vertical.common.exception.ConflictException
import com.vertical.common.exception.ErrorCode
import com.vertical.common.exception.ErrorDetails
import com.vertical.common.exception.ForbiddenException
import com.vertical.common.exception.GoneException
import com.vertical.common.exception.NotFoundException
import com.vertical.common.exception.UnprocessableEntityException
import com.vertical.common.pagination.PageParams
import com.vertical.common.pagination.PaginationMeta
import com.vertical.common.pagination.toPageable
import com.vertical.slots.entity.SlotEntity
import com.vertical.slots.repository.SlotRepository
import com.vertical.slots.service.SlotsService
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID

@Service
class BookingService(
    private val bookingRepository: BookingRepository,
    private val slotRepository: SlotRepository,
    private val idempotencyKeyRepository: IdempotencyKeyRepository,
    private val slotsService: SlotsService,
    private val objectMapper: ObjectMapper,
    private val clock: Clock,
) {

    @Transactional
    fun createBooking(
        clientId: UUID,
        idempotencyKey: UUID,
        request: CreateBookingRequest,
    ): CreateBookingResponse {
        validateEquipment(request.equipment)
        val requestHash = BookingRequestHasher.hash(request.slotId, request.equipment)
        resolveIdempotentReplay(clientId, idempotencyKey, requestHash)?.let { return it }

        val slot = slotRepository.findByIdForUpdate(request.slotId)
            .orElseThrow { NotFoundException() }

        validateSlotAvailable(slot)
        if (bookingRepository.existsByClientIdAndSlotIdAndStatus(
                clientId,
                request.slotId,
                BookingEntity.STATUS_ACTIVE,
            )
        ) {
            throw ConflictException(
                ErrorCode.DOUBLE_BOOKING,
                "Вы уже записаны на эту тренировку.",
            )
        }

        val availability = checkCapacity(slot, request.equipment)
        if (availability != null) {
            throw availability
        }

        val now = clock.instant()
        val priceTotal = calculatePrice(slot, request.equipment)
        val isFirstBooking = bookingRepository.countByClientId(clientId) == 0L

        slot.freeSeats -= 1
        if (request.equipment == BookingEntity.EQUIPMENT_RENTAL) {
            slot.freeRentalEquipment -= 1
        }
        slotRepository.save(slot)

        val booking = bookingRepository.save(
            BookingEntity(
                slotId = slot.id,
                clientId = clientId,
                equipment = request.equipment,
                priceTotal = priceTotal,
                createdAt = now,
            ),
        )

        val response = toCreateBookingResponse(booking, isFirstBooking)
        saveIdempotencyRecord(clientId, idempotencyKey, requestHash, response)
        return response
    }

    @Transactional(readOnly = true)
    fun listBookings(
        clientId: UUID,
        statuses: List<String>?,
        page: PageParams,
    ): BookingListResponse {
        validateStatuses(statuses)
        val specification = BookingSpecifications.forClient(clientId, statuses)
        val result = bookingRepository.findAll(specification, page.toPageable())

        return BookingListResponse(
            items = result.content.map { toBookingSummaryDto(it) },
            meta = PaginationMeta(
                limit = page.limit,
                offset = page.offset,
                total = result.totalElements.toInt(),
            ),
        )
    }

    @Transactional(readOnly = true)
    fun getBooking(clientId: UUID, bookingId: UUID): BookingDto {
        val booking = bookingRepository.findById(bookingId).orElseThrow { NotFoundException() }
        if (booking.clientId != clientId) {
            throw ForbiddenException()
        }
        return toBookingDto(booking)
    }

    @Transactional
    fun cancelBooking(clientId: UUID, bookingId: UUID): BookingDto {
        val booking = bookingRepository.findById(bookingId).orElseThrow { NotFoundException() }
        if (booking.clientId != clientId) {
            throw ForbiddenException()
        }
        if (booking.status != BookingEntity.STATUS_ACTIVE) {
            throw ConflictException(
                ErrorCode.ALREADY_CANCELLED,
                "Запись уже отменена.",
            )
        }

        val slot = slotRepository.findById(booking.slotId).orElseThrow { NotFoundException() }
        val now = clock.instant()
        if (!slot.startAt.isAfter(now)) {
            throw UnprocessableEntityException(
                ErrorCode.SLOT_STARTED,
                "Тренировка уже началась, отменить запись нельзя.",
            )
        }

        val isEarlyCancel = !now.isAfter(slot.startAt.minus(EARLY_CANCEL_THRESHOLD_HOURS, ChronoUnit.HOURS))
        if (isEarlyCancel) {
            booking.status = BookingEntity.STATUS_CANCELLED
            releaseSlotCapacity(booking, slot.id)
        } else {
            booking.status = BookingEntity.STATUS_LATE_CANCEL
        }

        booking.cancelledAt = now
        bookingRepository.save(booking)
        return toBookingDto(booking)
    }

    private fun releaseSlotCapacity(booking: BookingEntity, slotId: UUID) {
        val slot = slotRepository.findByIdForUpdate(slotId).orElseThrow { NotFoundException() }
        slot.freeSeats += 1
        if (booking.equipment == BookingEntity.EQUIPMENT_RENTAL) {
            slot.freeRentalEquipment += 1
        }
        slotRepository.save(slot)
    }

    private fun validateStatuses(statuses: List<String>?) {
        statuses?.forEach { status ->
            if (status !in BookingEntity.ALL_STATUSES) {
                throw BadRequestException("Unknown booking status: $status")
            }
        }
    }

    private fun toBookingDto(booking: BookingEntity): BookingDto =
        BookingDto(
            id = booking.id,
            slotId = booking.slotId,
            clientId = booking.clientId,
            equipment = booking.equipment,
            status = booking.status,
            priceTotal = booking.priceTotal,
            createdAt = booking.createdAt,
            cancelledAt = booking.cancelledAt,
            cancellationReason = booking.cancellationReason,
            slot = slotsService.getSlot(booking.slotId),
        )

    private fun toBookingSummaryDto(booking: BookingEntity): BookingSummaryDto =
        BookingSummaryDto(
            id = booking.id,
            slotId = booking.slotId,
            equipment = booking.equipment,
            status = booking.status,
            priceTotal = booking.priceTotal,
            createdAt = booking.createdAt,
            cancelledAt = booking.cancelledAt,
            cancellationReason = booking.cancellationReason,
            slot = slotsService.getSlot(booking.slotId),
        )

    private fun validateEquipment(equipment: String) {
        if (equipment !in VALID_EQUIPMENT) {
            throw BadRequestException("Unknown equipment value: $equipment")
        }
    }

    private fun validateSlotAvailable(slot: SlotEntity) {
        if (slot.status == SlotEntity.STATUS_CANCELLED) {
            throw GoneException()
        }
        if (!slot.startAt.isAfter(clock.instant())) {
            throw UnprocessableEntityException(
                ErrorCode.SLOT_STARTED,
                "Тренировка уже началась, запись недоступна.",
            )
        }
    }

    private fun checkCapacity(slot: SlotEntity, equipment: String): ConflictException? {
        if (slot.freeSeats <= 0) {
            return ConflictException(
                ErrorCode.SLOT_FULL,
                "На выбранной тренировке не осталось свободных мест.",
                ErrorDetails(
                    availableSeats = slot.freeSeats,
                    availableRentalEquipment = slot.freeRentalEquipment,
                ),
            )
        }
        if (equipment == BookingEntity.EQUIPMENT_RENTAL && slot.freeRentalEquipment <= 0) {
            return ConflictException(
                ErrorCode.RENTAL_UNAVAILABLE,
                "Прокатное снаряжение закончилось.",
                ErrorDetails(
                    availableSeats = slot.freeSeats,
                    availableRentalEquipment = slot.freeRentalEquipment,
                ),
            )
        }
        return null
    }

    private fun calculatePrice(slot: SlotEntity, equipment: String): Int =
        when (equipment) {
            BookingEntity.EQUIPMENT_OWN -> slot.price
            BookingEntity.EQUIPMENT_RENTAL -> slot.price + slot.rentalPrice
            else -> throw BadRequestException()
        }

    private fun resolveIdempotentReplay(
        clientId: UUID,
        idempotencyKey: UUID,
        requestHash: String,
    ): CreateBookingResponse? {
        val existing = idempotencyKeyRepository.findByClientIdAndIdempotencyKey(clientId, idempotencyKey)
            ?: return null

        if (existing.expiresAt.isBefore(clock.instant())) {
            idempotencyKeyRepository.delete(existing)
            return null
        }

        if (existing.requestHash != requestHash) {
            throw ConflictException(
                ErrorCode.IDEMPOTENCY_KEY_CONFLICT,
                "Повторный запрос с тем же Idempotency-Key, но другим телом.",
            )
        }

        val body = existing.responseBody
            ?: throw ConflictException(
                ErrorCode.IDEMPOTENCY_KEY_CONFLICT,
                "Повторный запрос с тем же Idempotency-Key, но другим телом.",
            )
        return objectMapper.readValue(body, CreateBookingResponse::class.java)
    }

    private fun saveIdempotencyRecord(
        clientId: UUID,
        idempotencyKey: UUID,
        requestHash: String,
        response: CreateBookingResponse,
    ) {
        val now = clock.instant()
        idempotencyKeyRepository.save(
            IdempotencyKeyEntity(
                clientId = clientId,
                idempotencyKey = idempotencyKey,
                requestHash = requestHash,
                responseStatus = HttpStatus.CREATED.value(),
                responseBody = objectMapper.writeValueAsString(response),
                createdAt = now,
                expiresAt = now.plus(IDEMPOTENCY_TTL_HOURS, ChronoUnit.HOURS),
            ),
        )
    }

    private fun toCreateBookingResponse(booking: BookingEntity, isFirstBooking: Boolean): CreateBookingResponse {
        val bookingDto = toBookingDto(booking)
        return CreateBookingResponse(
            id = bookingDto.id,
            slotId = bookingDto.slotId,
            clientId = bookingDto.clientId,
            equipment = bookingDto.equipment,
            status = bookingDto.status,
            priceTotal = bookingDto.priceTotal,
            createdAt = bookingDto.createdAt,
            cancelledAt = bookingDto.cancelledAt,
            cancellationReason = bookingDto.cancellationReason,
            slot = bookingDto.slot,
            isFirstBooking = isFirstBooking,
        )
    }

    companion object {
        private const val IDEMPOTENCY_TTL_HOURS = 24L
        private const val EARLY_CANCEL_THRESHOLD_HOURS = 2L
        private val VALID_EQUIPMENT = setOf(BookingEntity.EQUIPMENT_OWN, BookingEntity.EQUIPMENT_RENTAL)
    }
}
