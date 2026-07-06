package com.vertical.slots.service

import com.vertical.common.exception.BadRequestException
import com.vertical.common.exception.NotFoundException
import com.vertical.common.pagination.PageParams
import com.vertical.common.pagination.PaginationMeta
import com.vertical.common.pagination.toPageable
import com.vertical.instructors.service.CatalogService
import com.vertical.slots.dto.SlotDto
import com.vertical.slots.dto.SlotListResponse
import com.vertical.slots.entity.SlotEntity
import com.vertical.slots.repository.SlotRepository
import com.vertical.slots.repository.SlotSpecifications
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID

@Service
class SlotsService(
    private val slotRepository: SlotRepository,
    private val catalogService: CatalogService,
    private val clock: Clock,
) {

    @Transactional(readOnly = true)
    fun listSlots(
        dateFrom: Instant?,
        dateTo: Instant?,
        zoneFormatTypes: List<String>?,
        instructorIds: List<UUID>?,
        onlyAvailable: Boolean,
        page: PageParams,
    ): SlotListResponse {
        val resolvedFrom = dateFrom ?: clock.instant()
        val resolvedTo = dateTo ?: resolvedFrom.plus(DEFAULT_RANGE_DAYS, ChronoUnit.DAYS)

        if (resolvedTo.isBefore(resolvedFrom)) {
            throw BadRequestException("date_to must be greater than or equal to date_from")
        }

        zoneFormatTypes?.forEach { validateZoneFormatType(it) }

        val specification = SlotSpecifications.withFilters(
            dateFrom = resolvedFrom,
            dateTo = resolvedTo,
            zoneFormatTypes = zoneFormatTypes,
            instructorIds = instructorIds,
            onlyAvailable = onlyAvailable,
        )
        val pageable = page.toPageable(Sort.by("startAt").ascending())
        val result = slotRepository.findAll(specification, pageable)

        return SlotListResponse(
            items = result.content.map { toSlotDto(it) },
            meta = PaginationMeta(
                limit = page.limit,
                offset = page.offset,
                total = result.totalElements.toInt(),
            ),
        )
    }

    @Transactional(readOnly = true)
    fun getSlot(slotId: UUID): SlotDto {
        val slot = slotRepository.findById(slotId).orElseThrow { NotFoundException() }
        return toSlotDto(slot)
    }

    private fun toSlotDto(slot: SlotEntity): SlotDto {
        val zoneFormat = catalogService.getZoneFormat(slot.zoneFormatId)
            ?: throw NotFoundException()
        val instructor = catalogService.getInstructor(slot.instructorId)
            ?: throw NotFoundException()
        return SlotDto(
            id = slot.id,
            startAt = slot.startAt,
            zoneFormat = zoneFormat,
            instructorInfo = instructor,
            totalSeats = slot.totalSeats,
            freeSeats = slot.freeSeats,
            freeRentalEquipment = slot.freeRentalEquipment,
            price = slot.price,
            rentalPrice = slot.rentalPrice,
            status = slot.status,
        )
    }

    private fun validateZoneFormatType(type: String) {
        if (type !in VALID_ZONE_FORMAT_TYPES) {
            throw BadRequestException("Unknown zone_format_type: $type")
        }
    }

    companion object {
        private const val DEFAULT_RANGE_DAYS = 7L
        private val VALID_ZONE_FORMAT_TYPES = setOf("novice", "experienced")
    }
}
