package com.vertical.auth.repository

import com.vertical.auth.entity.AuthSessionEntity
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface AuthSessionRepository : JpaRepository<AuthSessionEntity, UUID> {
    fun findByRefreshTokenHashAndRevokedAtIsNull(refreshTokenHash: String): AuthSessionEntity?

    fun findByClientIdAndRevokedAtIsNull(clientId: UUID): List<AuthSessionEntity>
}
