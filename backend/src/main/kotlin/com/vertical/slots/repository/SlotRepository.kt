package com.vertical.slots.repository

import com.vertical.slots.entity.SlotEntity
import jakarta.persistence.LockModeType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Query
import java.util.Optional
import java.util.UUID

interface SlotRepository : JpaRepository<SlotEntity, UUID>, JpaSpecificationExecutor<SlotEntity> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT s FROM SlotEntity s WHERE s.id = :id")
    fun findByIdForUpdate(id: UUID): Optional<SlotEntity>
}
