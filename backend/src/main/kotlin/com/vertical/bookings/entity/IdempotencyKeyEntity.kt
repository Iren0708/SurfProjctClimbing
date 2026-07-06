package com.vertical.bookings.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "idempotency_keys")
class IdempotencyKeyEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(name = "client_id", nullable = false)
    val clientId: UUID,
    @Column(name = "idempotency_key", nullable = false)
    val idempotencyKey: UUID,
    @Column(name = "request_hash", nullable = false)
    val requestHash: String,
    @Column(name = "response_status")
    var responseStatus: Int? = null,
    @Column(name = "response_body", columnDefinition = "TEXT")
    var responseBody: String? = null,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
    @Column(name = "expires_at", nullable = false)
    val expiresAt: Instant,
)
