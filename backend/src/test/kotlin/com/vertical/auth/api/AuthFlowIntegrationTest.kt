package com.vertical.auth.api

import com.vertical.support.PostgresIntegrationTest
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.post

class AuthFlowIntegrationTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `login flow request verify refresh logout`() {
        val phone = "+79991234567"

        mockMvc.post("/v1/auth/request-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.ttl_seconds") { value(300) }
            jsonPath("$.resend_after_seconds") { value(60) }
        }

        val verifyResponse = mockMvc.post("/v1/auth/verify-code") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"phone":"$phone","code":"1234"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.is_new") { value(true) }
            jsonPath("$.client.phone") { value(phone) }
            jsonPath("$.tokens.access_token") { exists() }
            jsonPath("$.tokens.refresh_token") { exists() }
        }.andReturn().response.contentAsString

        val refreshToken = Regex(""""refresh_token"\s*:\s*"([^"]+)"""")
            .find(verifyResponse)
            ?.groupValues
            ?.get(1)
            ?: error("refresh_token not found")

        val refreshed = mockMvc.post("/v1/auth/refresh") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"refresh_token":"$refreshToken"}"""
        }.andExpect {
            status { isOk() }
            jsonPath("$.access_token") { exists() }
            jsonPath("$.refresh_token") { exists() }
        }.andReturn().response.contentAsString

        val newAccessToken = Regex(""""access_token"\s*:\s*"([^"]+)"""")
            .find(refreshed)
            ?.groupValues
            ?.get(1)
            ?: error("access_token not found")

        mockMvc.post("/v1/auth/logout") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $newAccessToken")
        }.andExpect {
            status { isNoContent() }
        }

        val newRefreshToken = Regex(""""refresh_token"\s*:\s*"([^"]+)"""")
            .find(refreshed)
            ?.groupValues
            ?.get(1)
            ?: error("refresh_token not found")

        mockMvc.post("/v1/auth/refresh") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"refresh_token":"$newRefreshToken"}"""
        }.andExpect {
            status { isUnauthorized() }
            jsonPath("$.code") { value("unauthorized") }
        }
    }
}
