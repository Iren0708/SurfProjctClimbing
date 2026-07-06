package com.vertical.bookings.entity

import com.vertical.slots.entity.SlotEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import java.time.Instant
import java.util.UUID

@Entity
@Table(name = "bookings")
class BookingEntity(
    @Id
    val id: UUID = UUID.randomUUID(),
    @Column(name = "slot_id", nullable = false)
    val slotId: UUID,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "slot_id", insertable = false, updatable = false)
    val slot: SlotEntity? = null,
    @Column(name = "client_id", nullable = false)
    val clientId: UUID,
    @Column(nullable = false)
    val equipment: String,
    @Column(nullable = false)
    var status: String = STATUS_ACTIVE,
    @Column(name = "price_total", nullable = false)
    val priceTotal: Int,
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant,
    @Column(name = "cancelled_at")
    var cancelledAt: Instant? = null,
    @Column(name = "cancellation_reason")
    var cancellationReason: String? = null,
) {
    companion object {
        const val STATUS_ACTIVE = "active"
        const val STATUS_CANCELLED = "cancelled"
        const val STATUS_LATE_CANCEL = "late_cancel"
        const val STATUS_CLUB_CANCELLED = "club_cancelled"
        const val EQUIPMENT_OWN = "own"
        const val EQUIPMENT_RENTAL = "rental"

        val ALL_STATUSES = setOf(
            STATUS_ACTIVE,
            STATUS_CANCELLED,
            STATUS_LATE_CANCEL,
            STATUS_CLUB_CANCELLED,
        )
    }
}
