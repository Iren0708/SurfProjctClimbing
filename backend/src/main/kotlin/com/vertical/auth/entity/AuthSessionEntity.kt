package com.vertical.auth.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "auth_sessions")
class AuthSessionEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(name = "client_id", nullable = false)
    val clientId: UUID,
    @Column(name = "refresh_token_hash", nullable = false, unique = true)
    val refreshTokenHash: String,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
    @Column(name = "expires_at", nullable = false)
    val expiresAt: Instant,
    @Column(name = "revoked_at")
    var revokedAt: Instant? = null,
)
