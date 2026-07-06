package com.vertical.auth.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "clients")
class ClientEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column
    var name: String? = null,
    @Column(nullable = false)
    var phone: String,
    @Column(name = "phone_anonymized", nullable = false)
    var phoneAnonymized: Boolean = false,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
    @Column(name = "deleted_at")
    var deletedAt: Instant? = null,
)
