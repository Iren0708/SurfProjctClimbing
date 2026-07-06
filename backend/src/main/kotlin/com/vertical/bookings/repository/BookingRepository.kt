package com.vertical.bookings.repository

import com.vertical.bookings.entity.BookingEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import java.util.UUID

interface BookingRepository : JpaRepository<BookingEntity, UUID>, JpaSpecificationExecutor<BookingEntity> {
    fun findByClientIdAndStatus(clientId: UUID, status: String): List<BookingEntity>

    fun existsByClientIdAndSlotIdAndStatus(clientId: UUID, slotId: UUID, status: String): Boolean

    fun countByClientId(clientId: UUID): Long
}
