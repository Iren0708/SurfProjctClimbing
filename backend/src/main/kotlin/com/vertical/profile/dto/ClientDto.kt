package com.vertical.profile.dto

import com.fasterxml.jackson.annotation.JsonInclude
import com.vertical.auth.entity.ClientEntity
import java.time.Instant
import java.util.UUID

@JsonInclude(JsonInclude.Include.NON_NULL)
data class ClientDto(
    val id: UUID,
    val name: String?,
    val phone: String,
    val createdAt: Instant,
)

fun ClientEntity.toDto(): ClientDto =
    ClientDto(
        id = id,
        name = name,
        phone = phone,
        createdAt = createdAt,
    )
