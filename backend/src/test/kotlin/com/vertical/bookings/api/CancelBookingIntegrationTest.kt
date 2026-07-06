package com.vertical.bookings.api

import com.vertical.support.PostgresIntegrationTest
import com.vertical.auth.entity.ClientEntity
import com.vertical.auth.repository.ClientRepository
import com.vertical.auth.security.JwtService
import com.vertical.bookings.entity.BookingEntity
import com.vertical.bookings.repository.BookingRepository
import com.vertical.instructors.entity.InstructorEntity
import com.vertical.instructors.entity.ZoneFormatEntity
import com.vertical.instructors.repository.InstructorRepository
import com.vertical.instructors.repository.ZoneFormatRepository
import com.vertical.slots.entity.SlotEntity
import com.vertical.slots.repository.SlotRepository
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.post
import java.time.Clock
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID

class CancelBookingIntegrationTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var clientRepository: ClientRepository

    @Autowired
    private lateinit var jwtService: JwtService

    @Autowired
    private lateinit var zoneFormatRepository: ZoneFormatRepository

    @Autowired
    private lateinit var instructorRepository: InstructorRepository

    @Autowired
    private lateinit var slotRepository: SlotRepository

    @Autowired
    private lateinit var bookingRepository: BookingRepository

    @Autowired
    private lateinit var clock: Clock

    private lateinit var accessToken: String
    private lateinit var clientId: UUID
    private lateinit var zoneFormatId: UUID
    private lateinit var instructorId: UUID

    @BeforeEach
    fun setUp() {
        bookingRepository.deleteAll()
        slotRepository.deleteAll()

        val now = clock.instant()
        clientId = UUID.fromString("cccccccc-cccc-cccc-cccc-cccccccccccc")
        clientRepository.save(
            ClientEntity(id = clientId, phone = "+79998887766", createdAt = now),
        )
        accessToken = jwtService.createAccessToken(
            clientId,
            UUID.fromString("dddddddd-dddd-dddd-dddd-dddddddddddd"),
        ).value

        zoneFormatId = zoneFormatRepository.save(
            ZoneFormatEntity(
                id = UUID.fromString("11111111-1111-1111-1111-111111111101"),
                name = "Болдеринг",
                type = "novice",
                capacityCap = 8,
                durationMin = 90,
                createdAt = now,
            ),
        ).id
        instructorId = instructorRepository.save(
            InstructorEntity(
                id = UUID.fromString("33333333-3333-3333-3333-333333333333"),
                name = "Анна",
                createdAt = now,
            ),
        ).id
    }

    @Test
    fun `early cancel from 2 hours or more releases seat and rental`() {
        val startAt = clock.instant().plus(2, ChronoUnit.HOURS).plus(1, ChronoUnit.SECONDS)
        val slot = saveSlot(startAt = startAt, freeSeats = 1, freeRental = 0)
        val bookingId = saveBooking(slot.id, BookingEntity.EQUIPMENT_RENTAL).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.status") { value("cancelled") }
            jsonPath("$.cancelled_at") { exists() }
        }

        val updatedSlot = slotRepository.findById(slot.id).orElseThrow()
        assertEquals(2, updatedSlot.freeSeats)
        assertEquals(1, updatedSlot.freeRentalEquipment)
    }

    @Test
    fun `late cancel below 2 hours does not release capacity`() {
        val now = clock.instant()
        val slot = saveSlot(
            startAt = now.plus(2, ChronoUnit.HOURS).minus(1, ChronoUnit.SECONDS),
            freeSeats = 1,
            freeRental = 0,
        )
        val bookingId = saveBooking(slot.id, BookingEntity.EQUIPMENT_RENTAL).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.status") { value("late_cancel") }
        }

        val updatedSlot = slotRepository.findById(slot.id).orElseThrow()
        assertEquals(1, updatedSlot.freeSeats)
        assertEquals(0, updatedSlot.freeRentalEquipment)
    }

    @Test
    fun `cancel after slot started returns 422`() {
        val now = clock.instant()
        val slot = saveSlot(startAt = now.minus(1, ChronoUnit.MINUTES), freeSeats = 1, freeRental = 1)
        val bookingId = saveBooking(slot.id, BookingEntity.EQUIPMENT_OWN).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isUnprocessableEntity() }
            jsonPath("$.code") { value("slot_started") }
        }

        val booking = bookingRepository.findById(bookingId).orElseThrow()
        assertEquals(BookingEntity.STATUS_ACTIVE, booking.status)
    }

    @Test
    fun `cancel already cancelled booking returns 409`() {
        val now = clock.instant()
        val slot = saveSlot(startAt = now.plus(1, ChronoUnit.DAYS), freeSeats = 1, freeRental = 1)
        val bookingId = bookingRepository.save(
            BookingEntity(
                slotId = slot.id,
                clientId = clientId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                status = BookingEntity.STATUS_CANCELLED,
                priceTotal = 1200,
                createdAt = now,
                cancelledAt = now,
            ),
        ).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("already_cancelled") }
        }
    }

    @Test
    fun `cancel another client booking returns 403`() {
        val now = clock.instant()
        val otherClientId = UUID.fromString("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee")
        clientRepository.save(ClientEntity(id = otherClientId, phone = "+79990001122", createdAt = now))
        val slot = saveSlot(startAt = now.plus(1, ChronoUnit.DAYS), freeSeats = 1, freeRental = 1)
        val bookingId = bookingRepository.save(
            BookingEntity(
                slotId = slot.id,
                clientId = otherClientId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                priceTotal = 1200,
                createdAt = now,
            ),
        ).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun `club cancelled booking cannot be cancelled again`() {
        val now = clock.instant()
        val slot = saveSlot(startAt = now.plus(1, ChronoUnit.DAYS), freeSeats = 1, freeRental = 1)
        val bookingId = bookingRepository.save(
            BookingEntity(
                slotId = slot.id,
                clientId = clientId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                status = BookingEntity.STATUS_CLUB_CANCELLED,
                priceTotal = 1200,
                createdAt = now,
                cancelledAt = now,
                cancellationReason = "Профилактика зоны",
            ),
        ).id

        mockMvc.post("/v1/bookings/$bookingId/cancel") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("already_cancelled") }
        }
    }

    private fun saveSlot(startAt: Instant, freeSeats: Int, freeRental: Int): SlotEntity {
        val now = clock.instant()
        return slotRepository.save(
            SlotEntity(
                zoneFormatId = zoneFormatId,
                instructorId = instructorId,
                startAt = startAt,
                totalSeats = 8,
                freeSeats = freeSeats,
                freeRentalEquipment = freeRental,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        )
    }

    private fun saveBooking(slotId: UUID, equipment: String): BookingEntity {
        val now = clock.instant()
        return bookingRepository.save(
            BookingEntity(
                slotId = slotId,
                clientId = clientId,
                equipment = equipment,
                priceTotal = if (equipment == BookingEntity.EQUIPMENT_RENTAL) 1600 else 1200,
                createdAt = now,
            ),
        )
    }
}
