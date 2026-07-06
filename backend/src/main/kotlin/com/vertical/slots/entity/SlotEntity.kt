package com.vertical.slots.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "slots")
class SlotEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(name = "zone_format_id", nullable = false)
    val zoneFormatId: UUID,
    @Column(name = "instructor_id", nullable = false)
    val instructorId: UUID,
    @Column(name = "start_at", nullable = false)
    val startAt: Instant,
    @Column(name = "total_seats", nullable = false)
    val totalSeats: Int,
    @Column(name = "free_seats", nullable = false)
    var freeSeats: Int,
    @Column(name = "free_rental_equipment", nullable = false)
    var freeRentalEquipment: Int,
    @Column(name = "rental_equipment_total", nullable = false)
    val rentalEquipmentTotal: Int,
    @Column(nullable = false)
    val price: Int,
    @Column(name = "rental_price", nullable = false)
    val rentalPrice: Int,
    @Column(nullable = false)
    val status: String = STATUS_SCHEDULED,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
) {
    companion object {
        const val STATUS_SCHEDULED = "scheduled"
        const val STATUS_CANCELLED = "cancelled"
    }
}
