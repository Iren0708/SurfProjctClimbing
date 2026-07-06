package com.vertical.auth.repository

import com.vertical.auth.entity.ClientEntity
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface ClientRepository : JpaRepository<ClientEntity, UUID> {
    fun findByPhoneAndDeletedAtIsNull(phone: String): ClientEntity?

    fun findByIdAndDeletedAtIsNull(id: UUID): ClientEntity?
}
