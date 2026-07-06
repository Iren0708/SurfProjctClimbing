package com.vertical.auth.security

import com.vertical.config.JwtProperties
import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.Instant
import java.util.Date
import java.util.UUID
import javax.crypto.SecretKey

@Service
class JwtService(
    private val jwtProperties: JwtProperties,
    private val clock: Clock,
) {
    private val secretKey: SecretKey by lazy {
        Keys.hmacShaKeyFor(jwtProperties.secret.toByteArray(Charsets.UTF_8))
    }

    fun createAccessToken(clientId: UUID, sessionId: UUID): AccessToken {
        val now = clock.instant()
        val expiresAt = now.plusSeconds(jwtProperties.accessTokenTtlSeconds)
        val token = Jwts.builder()
            .subject(clientId.toString())
            .claim(CLAIM_SESSION_ID, sessionId.toString())
            .issuedAt(Date.from(now))
            .expiration(Date.from(expiresAt))
            .signWith(secretKey)
            .compact()
        return AccessToken(
            value = token,
            expiresInSeconds = jwtProperties.accessTokenTtlSeconds,
            expiresAt = expiresAt,
        )
    }

    fun parseAccessToken(token: String): ClientPrincipal {
        val claims = parseClaims(token)
        val clientId = UUID.fromString(claims.subject)
        val sessionId = claims.get(CLAIM_SESSION_ID, String::class.java)?.let(UUID::fromString)
        return ClientPrincipal(clientId = clientId, sessionId = sessionId)
    }

    fun accessTokenExpiresAt(): Instant =
        clock.instant().plusSeconds(jwtProperties.accessTokenTtlSeconds)

    fun refreshTokenExpiresAt(): Instant =
        clock.instant().plusSeconds(jwtProperties.refreshTokenTtlSeconds)

    private fun parseClaims(token: String): Claims =
        Jwts.parser()
            .verifyWith(secretKey)
            .build()
            .parseSignedClaims(token)
            .payload

    data class AccessToken(
        val value: String,
        val expiresInSeconds: Long,
        val expiresAt: Instant,
    )

    companion object {
        private const val CLAIM_SESSION_ID = "sid"
    }
}
