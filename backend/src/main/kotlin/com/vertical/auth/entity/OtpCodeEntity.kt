package com.vertical.auth.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "otp_codes")
class OtpCodeEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(nullable = false)
    val phone: String,
    @Column(nullable = false)
    val purpose: String,
    @Column(name = "code_hash", nullable = false)
    val codeHash: String,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
    @Column(name = "expires_at", nullable = false)
    val expiresAt: Instant,
    @Column(name = "consumed_at")
    var consumedAt: Instant? = null,
    @Column(name = "attempt_count", nullable = false)
    var attemptCount: Int = 0,
)
