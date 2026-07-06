package com.vertical.auth.security

import com.vertical.config.JwtProperties
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertThrows
import org.junit.jupiter.api.Test
import java.time.Clock
import java.time.Instant
import java.time.ZoneOffset
import java.util.UUID

class JwtServiceTest {

    @Test
    fun `access token expires according to clock`() {
        val clientId = UUID.fromString("11111111-1111-1111-1111-111111111111")
        val sessionId = UUID.fromString("22222222-2222-2222-2222-222222222222")
        val issuedAt = Instant.parse("2020-01-01T00:00:00Z")
        val clock = Clock.fixed(issuedAt, ZoneOffset.UTC)
        val service = JwtService(
            jwtProperties = JwtProperties(
                secret = "test-jwt-secret-at-least-32-characters-long",
                accessTokenTtlSeconds = 60,
            ),
            clock = clock,
        )

        val token = service.createAccessToken(clientId, sessionId)
        assertEquals(issuedAt.plusSeconds(60), token.expiresAt)

        val expiredClock = Clock.fixed(issuedAt.plusSeconds(61), ZoneOffset.UTC)
        val expiredService = JwtService(
            jwtProperties = JwtProperties(
                secret = "test-jwt-secret-at-least-32-characters-long",
                accessTokenTtlSeconds = 60,
            ),
            clock = expiredClock,
        )
        assertThrows(Exception::class.java) {
            expiredService.parseAccessToken(token.value)
        }
    }
}
