package com.vertical.instructors.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "zone_formats")
class ZoneFormatEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(nullable = false)
    val name: String,
    @Column
    val description: String? = null,
    @Column(nullable = false)
    val type: String,
    @Column(name = "capacity_cap", nullable = false)
    val capacityCap: Int,
    @Column(name = "duration_min", nullable = false)
    val durationMin: Int,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
)

@Entity
@Table(name = "instructors")
class InstructorEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(nullable = false)
    val name: String,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
)
