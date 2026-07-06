package com.vertical.bookings.repository

import com.vertical.bookings.entity.IdempotencyKeyEntity
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface IdempotencyKeyRepository : JpaRepository<IdempotencyKeyEntity, UUID> {
    fun findByClientIdAndIdempotencyKey(clientId: UUID, idempotencyKey: UUID): IdempotencyKeyEntity?
}
