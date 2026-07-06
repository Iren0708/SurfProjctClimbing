package com.vertical.common.api

import com.vertical.support.PostgresIntegrationTest
import org.hamcrest.Matchers.hasKey
import org.hamcrest.Matchers.not
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

class ErrorResponseContractTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `bad request returns Error schema with code bad_request`() {
        mockMvc.post("/test-errors/bad-request") {
            contentType = MediaType.APPLICATION_JSON
            content = """{"name":""}"""
        }.andExpect {
            status { isBadRequest() }
            content { contentType(MediaType.APPLICATION_JSON) }
            jsonPath("$.code") { value("bad_request") }
            jsonPath("$.message") { exists() }
            jsonPath("$.details") { doesNotExist() }
        }
    }

    @Test
    fun `unauthorized returns Error schema with code unauthorized`() {
        mockMvc.get("/test-errors/unauthorized")
            .andExpect {
                status { isUnauthorized() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$.code") { value("unauthorized") }
                jsonPath("$.message") { exists() }
            }
    }

    @Test
    fun `not found returns Error schema with code not_found`() {
        mockMvc.get("/test-errors/not-found")
            .andExpect {
                status { isNotFound() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$.code") { value("not_found") }
                jsonPath("$.message") { exists() }
            }
    }

    @Test
    fun `unknown route returns Error schema with code not_found`() {
        mockMvc.get("/does-not-exist")
            .andExpect {
                status { isNotFound() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$.code") { value("not_found") }
                jsonPath("$.message") { exists() }
            }
    }

    @Test
    fun `error body contains only contract fields`() {
        mockMvc.get("/test-errors/not-found")
            .andExpect {
                status { isNotFound() }
                jsonPath("$") { value(hasKey("code")) }
                jsonPath("$") { value(hasKey("message")) }
                jsonPath("$") { value(not(hasKey("timestamp"))) }
                jsonPath("$") { value(not(hasKey("path"))) }
            }
    }
}
