package com.vertical.profile.api

import com.vertical.support.PostgresIntegrationTest
import com.vertical.bookings.entity.BookingEntity
import com.vertical.bookings.repository.BookingRepository
import com.vertical.slots.entity.SlotEntity
import com.vertical.slots.repository.SlotRepository
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.patch
import org.springframework.test.web.servlet.post
import java.time.Clock
import java.time.Instant
import java.util.UUID

class ProfileIntegrationTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var slotRepository: SlotRepository

    @Autowired
    private lateinit var bookingRepository: BookingRepository

    @Autowired
    private lateinit var clock: Clock

    @Test
    fun `profile get update delete and phone reuse after account deletion`() {
        val phone = "+79997654321"
        val accessToken = registerAndGetAccessToken(phone)

        mockMvc.get("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isOk() }
            jsonPath("$.phone") { value(phone) }
            jsonPath("$.name") { doesNotExist() }
        }

        mockMvc.patch("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":"Иван"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.name") { value("Иван") }
        }

        mockMvc.delete("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isNoContent() }
        }

        mockMvc.get("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isUnauthorized() }
        }

        mockMvc.post("/v1/auth/request-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone"}"""
        }.andExpect {
            status { isOk() }
        }

        mockMvc.post("/v1/auth/verify-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone","code":"1234"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.is_new") { value(true) }
        }
    }

    @Test
    fun `delete account cancels active booking and releases slot capacity`() {
        val phone = "+79995554433"
        val accessToken = registerAndGetAccessToken(phone)
        val clientId = extractClientId(accessToken)
        val slot = createSlot(freeSeats = 4, freeRentalEquipment = 2)

        bookingRepository.save(
            BookingEntity(
                slotId = slot.id,
                clientId = clientId,
                equipment = BookingEntity.EQUIPMENT_RENTAL,
                priceTotal = 1500,
                createdAt = clock.instant(),
            ),
        )

        mockMvc.delete("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $accessToken")
        }.andExpect {
            status { isNoContent() }
        }

        val updatedSlot = slotRepository.findById(slot.id).orElseThrow()
        assert(updatedSlot.freeSeats == 5)
        assert(updatedSlot.freeRentalEquipment == 3)

        val booking = bookingRepository.findAll().first { it.clientId == clientId }
        assert(booking.status == BookingEntity.STATUS_CANCELLED)
        assert(booking.cancelledAt != null)
    }

    private fun createSlot(freeSeats: Int, freeRentalEquipment: Int): SlotEntity {
        val now = clock.instant()
        return slotRepository.save(
            SlotEntity(
                zoneFormatId = UUID.fromString("11111111-1111-1111-1111-111111111101"),
                instructorId = UUID.fromString("33333333-3333-3333-3333-333333333333"),
                startAt = now.plusSeconds(3600),
                totalSeats = 8,
                freeSeats = freeSeats,
                freeRentalEquipment = freeRentalEquipment,
                rentalEquipmentTotal = 5,
                price = 1000,
                rentalPrice = 500,
                createdAt = now,
            ),
        )
    }

    private fun extractClientId(accessToken: String): UUID {
        val payload = accessToken.split(".")[1]
        val decoded = String(java.util.Base64.getUrlDecoder().decode(payload))
        val match = Regex(""""sub"\s*:\s*"([^"]+)"""").find(decoded)
            ?: error("sub claim not found")
        return UUID.fromString(match.groupValues[1])
    }

    private fun registerAndGetAccessToken(phone: String): String {
        mockMvc.post("/v1/auth/request-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone"}"""
        }.andExpect { status { isOk() } }

        val verifyResponse = mockMvc.post("/v1/auth/verify-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone","code":"1234"}"""
        }.andExpect { status { isOk() } }
            .andReturn().response.contentAsString

        return Regex(""""access_token"\s*:\s*"([^"]+)"""")
            .find(verifyResponse)
            ?.groupValues
            ?.get(1)
            ?: error("access_token not found")
    }
}
