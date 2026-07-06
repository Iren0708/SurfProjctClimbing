package com.vertical.config

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.vertical.support.PostgresIntegrationTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

/**
 * BE-15: сверка реализованного API с MVP-скоупом `01-analysis/api/` и экранами `5-mobile-app-spec`.
 */
class ApiMvpScopeContractTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @Test
    fun `mvp endpoints match openApi contract paths and operationIds`() {
        val paths = loadApiDocsPaths()

        MVP_ENDPOINTS.forEach { endpoint ->
            val operation = paths.path(endpoint.path).path(endpoint.method)
            assertFalse(
                operation.isMissingNode,
                "Missing endpoint ${endpoint.method.uppercase()} ${endpoint.path}",
            )
            assertEquals(
                endpoint.operationId,
                operation.path("operationId").asText(),
                "operationId mismatch for ${endpoint.method.uppercase()} ${endpoint.path}",
            )
        }
    }

    @Test
    fun `no extra client api endpoints beyond mvp scope`() {
        val paths = loadApiDocsPaths()
        val documentedV1Paths = mutableSetOf<String>()

        paths.fields().forEachRemaining { pathEntry ->
            if (pathEntry.key.startsWith("/v1/")) {
                documentedV1Paths.add(pathEntry.key)
            }
        }

        val expectedPaths = MVP_ENDPOINTS.map { it.path }.toSet()
        val extraPaths = documentedV1Paths - expectedPaths

        assertTrue(
            extraPaths.isEmpty(),
            "Unexpected /v1 endpoints outside MVP scope: $extraPaths",
        )
    }

    @Test
    fun `phase 2 operationIds are not exposed`() {
        val operationIds = extractOperationIds(loadApiDocsPaths())

        PHASE2_OPERATION_IDS.forEach { phase2Id ->
            assertFalse(
                operationIds.contains(phase2Id),
                "Phase 2 operationId must not be implemented in MVP: $phase2Id",
            )
        }
    }

    @Test
    fun `all mvp screens have required api operations documented`() {
        val operationIds = extractOperationIds(loadApiDocsPaths())

        SCREEN_API_REQUIREMENTS.forEach { (screen, requiredOperations) ->
            val missing = requiredOperations - operationIds
            assertTrue(
                missing.isEmpty(),
                "$screen is missing API operations: $missing",
            )
        }
    }

    private fun loadApiDocsPaths(): JsonNode {
        val content = mockMvc.get("/v3/api-docs")
            .andExpect { status { isOk() } }
            .andReturn()
            .response
            .contentAsString
        return objectMapper.readTree(content).path("paths")
    }

    private fun extractOperationIds(paths: JsonNode): Set<String> {
        val operationIds = mutableSetOf<String>()
        paths.fields().forEachRemaining { pathEntry ->
            pathEntry.value.fields().forEachRemaining { methodEntry ->
                val operationId = methodEntry.value.path("operationId").asText(null)
                if (operationId != null) {
                    operationIds.add(operationId)
                }
            }
        }
        return operationIds
    }

    private data class ExpectedEndpoint(
        val method: String,
        val path: String,
        val operationId: String,
    )

    companion object {
        private val MVP_ENDPOINTS = listOf(
            ExpectedEndpoint("post", "/v1/auth/request-code", "requestAuthCode"),
            ExpectedEndpoint("post", "/v1/auth/verify-code", "verifyAuthCode"),
            ExpectedEndpoint("post", "/v1/auth/refresh", "refreshToken"),
            ExpectedEndpoint("post", "/v1/auth/logout", "logout"),
            ExpectedEndpoint("get", "/v1/profile", "getProfile"),
            ExpectedEndpoint("patch", "/v1/profile", "updateProfile"),
            ExpectedEndpoint("delete", "/v1/profile", "deleteAccount"),
            ExpectedEndpoint("get", "/v1/zone-formats", "listZoneFormats"),
            ExpectedEndpoint("get", "/v1/instructors", "listInstructors"),
            ExpectedEndpoint("get", "/v1/slots", "listSlots"),
            ExpectedEndpoint("get", "/v1/slots/{slotId}", "getSlot"),
            ExpectedEndpoint("post", "/v1/bookings", "createBooking"),
            ExpectedEndpoint("get", "/v1/bookings", "listBookings"),
            ExpectedEndpoint("get", "/v1/bookings/{bookingId}", "getBooking"),
            ExpectedEndpoint("post", "/v1/bookings/{bookingId}/cancel", "cancelBooking"),
        )

        private val PHASE2_OPERATION_IDS = setOf(
            "registerPushToken",
            "deletePushToken",
            "requestPhoneChangeCode",
            "confirmPhoneChange",
        )

        private val SCREEN_API_REQUIREMENTS = mapOf(
            "SCR-001" to setOf("requestAuthCode", "verifyAuthCode", "refreshToken"),
            "SCR-002" to setOf("listSlots", "listZoneFormats", "listInstructors"),
            "BS-001" to setOf("listSlots"),
            "SCR-003" to setOf("getSlot"),
            "SCR-004" to setOf("createBooking"),
            "BS-002" to setOf("createBooking"),
            "SCR-005" to setOf("listBookings"),
            "SCR-006" to setOf("getBooking", "cancelBooking"),
            "BS-003" to setOf("cancelBooking"),
            "SCR-007" to setOf("getProfile", "updateProfile", "deleteAccount", "logout"),
        )
    }
}
