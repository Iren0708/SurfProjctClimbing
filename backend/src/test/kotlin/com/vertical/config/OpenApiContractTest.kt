package com.vertical.config

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.vertical.support.PostgresIntegrationTest
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

class OpenApiContractTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var objectMapper: ObjectMapper

    @Test
    fun `openapi documents all mvp operationIds`() {
        val content = mockMvc.get("/v3/api-docs")
            .andExpect { status { isOk() } }
            .andReturn()
            .response
            .contentAsString

        val operationIds = extractOperationIds(objectMapper.readTree(content))

        assertTrue(
            operationIds.containsAll(MVP_OPERATION_IDS),
            "Missing operationIds: ${MVP_OPERATION_IDS - operationIds}",
        )
    }

    @Test
    fun `swagger ui is publicly available`() {
        mockMvc.get("/swagger-ui.html")
            .andExpect { status { is3xxRedirection() } }
    }

    private fun extractOperationIds(root: JsonNode): Set<String> {
        val operationIds = mutableSetOf<String>()
        val paths = root.path("paths")
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

    companion object {
        private val MVP_OPERATION_IDS = setOf(
            "requestAuthCode",
            "verifyAuthCode",
            "refreshToken",
            "logout",
            "getProfile",
            "updateProfile",
            "deleteAccount",
            "listZoneFormats",
            "listInstructors",
            "listSlots",
            "getSlot",
            "createBooking",
            "listBookings",
            "getBooking",
            "cancelBooking",
        )
    }
}
