package com.vertical.slots.api

import com.vertical.support.PostgresIntegrationTest
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
import org.springframework.test.web.servlet.get
import java.time.Clock
import java.time.temporal.ChronoUnit
import java.util.UUID

class CatalogIntegrationTest : PostgresIntegrationTest() {

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
    private lateinit var clock: Clock

    private lateinit var accessToken: String
    private lateinit var noviceSlotId: UUID
    private lateinit var fullSlotId: UUID

    @BeforeEach
    fun setUp() {
        val clientId = UUID.fromString("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
        val sessionId = UUID.fromString("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")
        clientRepository.save(
            ClientEntity(
                id = clientId,
                phone = "+79990001122",
                createdAt = clock.instant(),
            ),
        )
        accessToken = jwtService.createAccessToken(clientId, sessionId).value

        val now = clock.instant()
        val noviceFormat = zoneFormatRepository.save(
            ZoneFormatEntity(
                id = UUID.fromString("11111111-1111-1111-1111-111111111101"),
                name = "Болдеринг",
                description = "Для новичков",
                type = "novice",
                capacityCap = 8,
                durationMin = 90,
                createdAt = now,
            ),
        )
        val experiencedFormat = zoneFormatRepository.save(
            ZoneFormatEntity(
                id = UUID.fromString("11111111-1111-1111-1111-111111111102"),
                name = "Трассы",
                type = "experienced",
                capacityCap = 16,
                durationMin = 90,
                createdAt = now,
            ),
        )
        val anna = instructorRepository.save(
            InstructorEntity(
                id = UUID.fromString("33333333-3333-3333-3333-333333333333"),
                name = "Анна",
                createdAt = now,
            ),
        )
        val dmitry = instructorRepository.save(
            InstructorEntity(
                id = UUID.fromString("44444444-4444-4444-4444-444444444444"),
                name = "Дмитрий",
                createdAt = now,
            ),
        )

        noviceSlotId = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("55555555-5555-5555-5555-555555555501"),
                zoneFormatId = noviceFormat.id,
                instructorId = anna.id,
                startAt = now.plus(1, ChronoUnit.DAYS),
                totalSeats = 8,
                freeSeats = 5,
                freeRentalEquipment = 4,
                rentalEquipmentTotal = 6,
                price = 1200,
                rentalPrice = 400,
                createdAt = now,
            ),
        ).id

        fullSlotId = slotRepository.save(
            SlotEntity(
                id = UUID.fromString("55555555-5555-5555-5555-555555555503"),
                zoneFormatId = experiencedFormat.id,
                instructorId = dmitry.id,
                startAt = now.plus(2, ChronoUnit.DAYS),
                totalSeats = 12,
                freeSeats = 0,
                freeRentalEquipment = 3,
                rentalEquipmentTotal = 8,
                price = 1500,
                rentalPrice = 500,
                createdAt = now,
            ),
        ).id
    }

    @Test
    fun `catalog endpoints require authentication`() {
        mockMvc.get("/v1/zone-formats")
            .andExpect {
                status { isUnauthorized() }
                jsonPath("$.code") { value("unauthorized") }
            }
    }

    @Test
    fun `list zone formats and instructors with pagination`() {
        mockMvc.get("/v1/zone-formats") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.items.length()") { value(2) }
            jsonPath("$.meta.total") { value(2) }
            jsonPath("$.items[0].type") { exists() }
        }

        mockMvc.get("/v1/instructors") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.items.length()") { value(2) }
            jsonPath("$.items[0].name") { exists() }
        }
    }

    @Test
    fun `list slots supports filters and only available`() {
        mockMvc.get("/v1/slots") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            param("only_available", "true")
        }.andExpect {
            status { isOk() }
            jsonPath("$.items[?(@.id == '$noviceSlotId')]") { exists() }
            jsonPath("$.items[?(@.id == '$fullSlotId')]") { doesNotExist() }
        }

        mockMvc.get("/v1/slots") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            param("zone_format_type", "experienced")
        }.andExpect {
            status { isOk() }
            jsonPath("$.items[?(@.id == '$fullSlotId')]") { exists() }
            jsonPath("$.items[?(@.id == '$fullSlotId')].zone_format.type") { value("experienced") }
        }
    }

    @Test
    fun `get slot returns 404 for unknown id`() {
        mockMvc.get("/v1/slots/${UUID.randomUUID()}") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isNotFound() }
            jsonPath("$.code") { value("not_found") }
        }
    }

    @Test
    fun `get slot returns full card`() {
        mockMvc.get("/v1/slots/$noviceSlotId") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.id") { value(noviceSlotId.toString()) }
            jsonPath("$.zone_format.name") { value("Болдеринг") }
            jsonPath("$.instructor_info.name") { value("Анна") }
            jsonPath("$.free_seats") { value(5) }
        }
    }

    @Test
    fun `invalid zone format type returns bad request`() {
        mockMvc.get("/v1/slots") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            param("zone_format_type", "invalid")
        }.andExpect {
            status { isBadRequest() }
            jsonPath("$.code") { value("bad_request") }
        }
    }
}
