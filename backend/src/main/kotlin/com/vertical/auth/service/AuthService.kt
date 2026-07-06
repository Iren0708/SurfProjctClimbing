package com.vertical.auth.service

import com.vertical.auth.dto.TokenPairDto
import com.vertical.auth.dto.VerifyCodeResponse
import com.vertical.auth.entity.AuthSessionEntity
import com.vertical.auth.entity.ClientEntity
import com.vertical.auth.repository.AuthSessionRepository
import com.vertical.auth.repository.ClientRepository
import com.vertical.auth.security.ClientPrincipal
import com.vertical.auth.security.JwtService
import com.vertical.auth.support.TokenHasher
import com.vertical.common.exception.UnauthorizedException
import com.vertical.config.JwtProperties
import com.vertical.profile.dto.toDto
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

@Service
class AuthService(
    private val otpService: OtpService,
    private val clientRepository: ClientRepository,
    private val authSessionRepository: AuthSessionRepository,
    private val jwtService: JwtService,
    private val jwtProperties: JwtProperties,
    private val clock: Clock,
) {

    @Transactional
    fun verifyAuthCode(phone: String, code: String): VerifyCodeResponse {
        otpService.verifyLoginCode(phone, code)

        val existing = clientRepository.findByPhoneAndDeletedAtIsNull(phone)
        val isNew = existing == null
        val client = existing ?: clientRepository.save(
            ClientEntity(
                phone = phone,
                createdAt = clock.instant(),
            ),
        )

        val session = createSession(client.id)
        return VerifyCodeResponse(
            tokens = session.tokens,
            client = client.toDto(),
            isNew = isNew,
        )
    }

    @Transactional
    fun refreshToken(refreshToken: String): TokenPairDto {
        val session = authSessionRepository.findByRefreshTokenHashAndRevokedAtIsNull(
            TokenHasher.sha256(refreshToken),
        ) ?: throw UnauthorizedException()

        val now = clock.instant()
        if (session.expiresAt.isBefore(now)) {
            throw UnauthorizedException()
        }

        session.revokedAt = now
        authSessionRepository.save(session)

        return createSession(session.clientId).tokens
    }

    @Transactional
    fun logout(principal: ClientPrincipal) {
        val sessionId = principal.sessionId ?: throw UnauthorizedException()
        val session = authSessionRepository.findById(sessionId).orElseThrow { UnauthorizedException() }
        if (session.clientId != principal.clientId || session.revokedAt != null) {
            throw UnauthorizedException()
        }
        session.revokedAt = clock.instant()
        authSessionRepository.save(session)
    }

    private fun createSession(clientId: UUID): SessionWithTokens {
        val refreshToken = UUID.randomUUID().toString() + UUID.randomUUID().toString()
        val sessionId = UUID.randomUUID()
        val now = clock.instant()
        authSessionRepository.save(
            AuthSessionEntity(
                id = sessionId,
                clientId = clientId,
                refreshTokenHash = TokenHasher.sha256(refreshToken),
                createdAt = now,
                expiresAt = jwtService.refreshTokenExpiresAt(),
            ),
        )
        val access = jwtService.createAccessToken(clientId, sessionId)
        return SessionWithTokens(
            tokens = TokenPairDto(
                accessToken = access.value,
                refreshToken = refreshToken,
                expiresIn = access.expiresInSeconds,
            ),
        )
    }

    private data class SessionWithTokens(val tokens: TokenPairDto)
}
