package com.vertical.auth.security

import com.vertical.auth.entity.ClientEntity
import com.vertical.auth.repository.ClientRepository
import com.vertical.support.PostgresIntegrationTest
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import java.time.Instant
import java.util.Date
import java.util.UUID

class JwtSecurityContractTest : PostgresIntegrationTest() {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var jwtService: JwtService

    @Autowired
    private lateinit var clientRepository: ClientRepository

    @Test
    fun `protected endpoint returns unauthorized without bearer token`() {
        mockMvc.get("/v1/profile")
            .andExpect {
                status { isUnauthorized() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$.code") { value("unauthorized") }
            }
    }

    @Test
    fun `protected endpoint accepts valid bearer token`() {
        val clientId = UUID.fromString("11111111-1111-1111-1111-111111111111")
        val sessionId = UUID.fromString("22222222-2222-2222-2222-222222222222")
        clientRepository.save(
            ClientEntity(
                id = clientId,
                phone = "+79991111111",
                createdAt = Instant.now(),
            ),
        )
        val token = jwtService.createAccessToken(clientId, sessionId).value

        mockMvc.get("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $token")
        }.andExpect {
            status { isOk() }
            jsonPath("$.id") { value(clientId.toString()) }
        }
    }

    @Test
    fun `expired bearer token is rejected`() {
        val secret = Keys.hmacShaKeyFor(
            "test-jwt-secret-at-least-32-characters-long".toByteArray(Charsets.UTF_8),
        )
        val expiredToken = Jwts.builder()
            .subject("11111111-1111-1111-1111-111111111111")
            .issuedAt(Date.from(Instant.parse("2019-01-01T00:00:00Z")))
            .expiration(Date.from(Instant.parse("2019-01-01T00:01:00Z")))
            .signWith(secret)
            .compact()

        mockMvc.get("/v1/profile") {
            header(HttpHeaders.AUTHORIZATION, "Bearer $expiredToken")
        }.andExpect {
            status { isUnauthorized() }
            jsonPath("$.code") { value("unauthorized") }
        }
    }
}
