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
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post
import java.time.Clock
import java.time.temporal.ChronoUnit
import java.util.UUID

class BookingReadIntegrationTest : PostgresIntegrationTest() {

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

    private lateinit var ownerToken: String
    private lateinit var otherToken: String
    private lateinit var ownerId: UUID
    private lateinit var nearerBookingId: UUID
    private lateinit var laterBookingId: UUID
    private lateinit var cancelledBookingId: UUID

    @BeforeEach
    fun setUp() {
        bookingRepository.deleteAll()

        val now = clock.instant()
        ownerId = UUID.fromString("cccccccc-cccc-cccc-cccc-cccccccccccc")
        val otherClientId = UUID.fromString("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee")

        clientRepository.saveAll(
            listOf(
                ClientEntity(id = ownerId, phone = "+79998887766", createdAt = now),
                ClientEntity(id = otherClientId, phone = "+79991112233", createdAt = now),
            ),
        )

        ownerToken = jwtService.createAccessToken(
            ownerId,
            UUID.fromString("dddddddd-dddd-dddd-dddd-dddddddddddd"),
        ).value
        otherToken = jwtService.createAccessToken(
            otherClientId,
            UUID.fromString("ffffffff-ffff-ffff-ffff-ffffffffffff"),
        ).value

        val zoneFormat = zoneFormatRepository.save(
            ZoneFormatEntity(
                id = UUID.fromString("11111111-1111-1111-1111-111111111101"),
                name = "Болдеринг",
                type = "novice",
                capacityCap = 8,
                durationMin = 90,
                createdAt = now,
            ),
        )
        val instructor = instructorRepository.save(
            InstructorEntity(
                id = UUID.fromString("33333333-3333-3333-3333-333333333333"),
                name = "Анна",
                createdAt = now,
            ),
        )

        val nearerSlot = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666611"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(1, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 2,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        )
        val laterSlot = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666612"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(5, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 2,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1500,
                rentalPrice = 400,
                createdAt = now,
            ),
        )
        val otherClientSlot = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666613"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(3, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 2,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1300,
                rentalPrice = 400,
                createdAt = now,
            ),
        )

        val cancelledSlot = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666614"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(2, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 2,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        )

        nearerBookingId = bookingRepository.save(
            BookingEntity(
                id = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1"),
                slotId = nearerSlot.id,
                clientId = ownerId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                priceTotal = 1200,
                createdAt = now.minus(2, ChronoUnit.HOURS),
            ),
        ).id

        laterBookingId = bookingRepository.save(
            BookingEntity(
                id = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2"),
                slotId = laterSlot.id,
                clientId = ownerId,
                equipment = BookingEntity.EQUIPMENT_RENTAL,
                priceTotal = 1900,
                createdAt = now.minus(1, ChronoUnit.HOURS),
            ),
        ).id

        cancelledBookingId = bookingRepository.save(
            BookingEntity(
                id = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3"),
                slotId = cancelledSlot.id,
                clientId = ownerId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                status = BookingEntity.STATUS_CANCELLED,
                priceTotal = 1200,
                createdAt = now.minus(3, ChronoUnit.HOURS),
                cancelledAt = now.minus(30, ChronoUnit.MINUTES),
            ),
        ).id

        bookingRepository.save(
            BookingEntity(
                id = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4"),
                slotId = otherClientSlot.id,
                clientId = otherClientId,
                equipment = BookingEntity.EQUIPMENT_OWN,
                priceTotal = 1300,
                createdAt = now,
            ),
        )
    }

    @Test
    fun `listBookings returns only current client bookings sorted by slot start desc`() {
        mockMvc.get("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.meta.total") { value(3) }
            jsonPath("$.items.length()") { value(3) }
            jsonPath("$.items[0].id") { value(laterBookingId.toString()) }
            jsonPath("$.items[1].id") { value(cancelledBookingId.toString()) }
            jsonPath("$.items[2].id") { value(nearerBookingId.toString()) }
            jsonPath("$.items[0].slot.zone_format.name") { value("Болдеринг") }
            jsonPath("$.items[0].client_id") { doesNotExist() }
        }
    }

    @Test
    fun `listBookings filters by status`() {
        mockMvc.get("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
            param("status", "cancelled")
        }.andExpect {
            status { isOk() }
            jsonPath("$.meta.total") { value(1) }
            jsonPath("$.items[0].id") { value(cancelledBookingId.toString()) }
            jsonPath("$.items[0].status") { value("cancelled") }
        }
    }

    @Test
    fun `listBookings rejects unknown status`() {
        mockMvc.get("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
            param("status", "unknown")
        }.andExpect {
            status { isBadRequest() }
            jsonPath("$.code") { value("bad_request") }
        }
    }

    @Test
    fun `getBooking returns nested slot data`() {
        mockMvc.get("/v1/bookings/$nearerBookingId") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.id") { value(nearerBookingId.toString()) }
            jsonPath("$.client_id") { value(ownerId.toString()) }
            jsonPath("$.slot.instructor_info.name") { value("Анна") }
            jsonPath("$.slot.zone_format.type") { value("novice") }
        }
    }

    @Test
    fun `getBooking returns 403 for another client booking`() {
        val otherBookingId = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4")

        mockMvc.get("/v1/bookings/$otherBookingId") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
        }.andExpect {
            status { isForbidden() }
            jsonPath("$.code") { value("forbidden") }
        }
    }

    @Test
    fun `getBooking returns 404 when booking does not exist`() {
        mockMvc.get("/v1/bookings/${UUID.randomUUID()}") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $ownerToken")
        }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun `listBookings requires authentication`() {
        mockMvc.get("/v1/bookings").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun `created booking is visible in list and details`() {
        val slotId = UUID.fromString("66666666-6666-6666-6666-666666666611")
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $otherToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$slotId","equipment":"own"}"""
        }.andExpect { status { isCreated() } }

        mockMvc.get("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $otherToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.meta.total") { value(2) }
        }
    }
}
