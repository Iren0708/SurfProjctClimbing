package com.vertical.bookings.api

import com.vertical.support.PostgresIntegrationTest
import com.vertical.bookings.repository.BookingRepository
import com.vertical.bookings.repository.IdempotencyKeyRepository
import com.vertical.auth.entity.ClientEntity
import com.vertical.auth.repository.ClientRepository
import com.vertical.auth.security.JwtService
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
import org.springframework.test.web.servlet.post
import java.time.Clock
import java.time.temporal.ChronoUnit
import java.util.UUID
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import org.junit.jupiter.api.Assertions.assertEquals

class CreateBookingIntegrationTest : PostgresIntegrationTest() {

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
    private lateinit var idempotencyKeyRepository: IdempotencyKeyRepository

    @Autowired
    private lateinit var clock: Clock

    private lateinit var accessToken: String
    private lateinit var clientId: UUID
    private lateinit var availableSlotId: UUID
    private lateinit var fullSlotId: UUID
    private lateinit var cancelledSlotId: UUID

    @BeforeEach
    fun setUp() {
        bookingRepository.deleteAll()
        idempotencyKeyRepository.deleteAll()

        clientId = UUID.fromString("cccccccc-cccc-cccc-cccc-cccccccccccc")
        val sessionId = UUID.fromString("dddddddd-dddd-dddd-dddd-dddddddddddd")
        clientRepository.save(
            ClientEntity(
                id = clientId,
                phone = "+79998887766",
                createdAt = clock.instant(),
            ),
        )
        accessToken = jwtService.createAccessToken(clientId, sessionId).value

        val now = clock.instant()
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

        availableSlotId = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666601"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(2, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 3,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        ).id

        fullSlotId = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666602"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(3, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 0,
                freeRentalEquipment = 0,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        ).id

        cancelledSlotId = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("66666666-6666-6666-6666-666666666603"),
                zoneFormatId = zoneFormat.id,
                instructorId = instructor.id,
                startAt = now.plus(4, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 5,
                freeRentalEquipment = 2,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                status = SlotEntity.STATUS_CANCELLED,
                createdAt = now,
            ),
        ).id
    }

    @Test
    fun `create booking with own equipment returns 201`() {
        val idempotencyKey = UUID.randomUUID()
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", idempotencyKey.toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$availableSlotId","equipment":"own"}"""
        }.andExpect {
            status { isCreated() }
            jsonPath("$.price_total") { value(1200) }
            jsonPath("$.equipment") { value("own") }
            jsonPath("$.is_first_booking") { value(true) }
            jsonPath("$.reminder_hours[0]") { value(24) }
            jsonPath("$.slot.id") { value(availableSlotId.toString()) }
        }
    }

    @Test
    fun `create booking with rental calculates price total`() {
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$availableSlotId","equipment":"rental"}"""
        }.andExpect {
            status { isCreated() }
            jsonPath("$.price_total") { value(1600) }
        }
    }

    @Test
    fun `slot full returns 409 with details`() {
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$fullSlotId","equipment":"own"}"""
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("slot_full") }
            jsonPath("$.details.available_seats") { value(0) }
        }
    }

    @Test
    fun `cancelled slot returns 410`() {
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$cancelledSlotId","equipment":"own"}"""
        }.andExpect {
            status { isGone() }
            jsonPath("$.code") { value("slot_cancelled") }
        }
    }

    @Test
    fun `idempotent replay returns same booking`() {
        val idempotencyKey = UUID.randomUUID()
        val body = """{"slot_id":"$availableSlotId","equipment":"own"}"""
        val first = mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", idempotencyKey.toString())
            contentType = MediaType.APPLICATION_JSON
            content = body
        }.andExpect { status { isCreated() } }
            .andReturn().response.contentAsString

        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", idempotencyKey.toString())
            contentType = MediaType.APPLICATION_JSON
            content = body
        }.andExpect {
            status { isCreated() }
            content { string(first) }
        }
    }

    @Test
    fun `idempotency key conflict on different body returns 409`() {
        val idempotencyKey = UUID.randomUUID()
        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", idempotencyKey.toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$availableSlotId","equipment":"own"}"""
        }.andExpect { status { isCreated() } }

        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", idempotencyKey.toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$availableSlotId","equipment":"rental"}"""
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("idempotency_key_conflict") }
        }
    }

    @Test
    fun `double booking same slot returns 409`() {
        val slotId = slotRepository.save(
            copySlot(freeSeats = 5, startAt = clock.instant().plus(5, ChronoUnit.DAYS)),
        ).id

        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$slotId","equipment":"own"}"""
        }.andExpect { status { isCreated() } }

        mockMvc.post("/v1/bookings") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            header("Idempotency-Key", UUID.randomUUID().toString())
            contentType = MediaType.APPLICATION_JSON
            content = """{"slot_id":"$slotId","equipment":"own"}"""
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("double_booking") }
        }
    }

    @Test
    fun `concurrent bookings do not overbook last seat`() {
        val slotId = slotRepository.save(
            copySlot(freeSeats = 1, startAt = clock.instant().plus(6, ChronoUnit.DAYS)),
        ).id

        val executor = Executors.newFixedThreadPool(8)
        val created = AtomicInteger(0)
        val conflicts = AtomicInteger(0)

        try {
            val tasks = (1..8).map {
                Callable {
                    try {
                        mockMvc.post("/v1/bookings") {
                            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
                            header("Idempotency-Key", UUID.randomUUID().toString())
                            contentType = MediaType.APPLICATION_JSON
                            content = """{"slot_id":"$slotId","equipment":"own"}"""
                        }.andReturn().response.status
                    } catch (ex: Exception) {
                        500
                    }
                }
            }
            val results = executor.invokeAll(tasks, 30, TimeUnit.SECONDS)
            results.forEach { future ->
                when (future.get()) {
                    201 -> created.incrementAndGet()
                    409 -> conflicts.incrementAndGet()
                }
            }
        } finally {
            executor.shutdownNow()
        }

        assertEquals(1, created.get())
        assertEquals(7, conflicts.get())

        val slot = slotRepository.findById(slotId).orElseThrow()
        assertEquals(0, slot.freeSeats)
    }

    private fun copySlot(freeSeats: Int, startAt: java.time.Instant): SlotEntity {
        val now = clock.instant()
        return SlotEntity(
            zoneFormatId = UUID.fromString("11111111-1111-1111-1111-111111111101"),
            instructorId = UUID.fromString("33333333-3333-3333-3333-333333333333"),
            startAt = startAt,
            totalSeats = 8,
            freeSeats = freeSeats,
            freeRentalEquipment = 2,
            rentalEquipmentTotal = 6,
            price = 1200,
            rentalPrice = 400,
            createdAt = now,
        )
    }
}
