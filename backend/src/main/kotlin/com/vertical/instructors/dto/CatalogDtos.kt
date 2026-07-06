package com.vertical.instructors.dto

import com.fasterxml.jackson.annotation.JsonInclude
import com.vertical.instructors.entity.InstructorEntity
import com.vertical.instructors.entity.ZoneFormatEntity
import java.util.UUID

@JsonInclude(JsonInclude.Include.NON_NULL)
data class ZoneFormatDto(
    val id: UUID,
    val name: String,
    val description: String?,
    val type: String,
    val capacityCap: Int,
    val durationMin: Int,
)

data class InstructorDto(
    val id: UUID,
    val name: String,
)

data class ZoneFormatListResponse(
    val items: List<ZoneFormatDto>,
    val meta: com.vertical.common.pagination.PaginationMeta,
)

data class InstructorListResponse(
    val items: List<InstructorDto>,
    val meta: com.vertical.common.pagination.PaginationMeta,
)

fun ZoneFormatEntity.toDto(): ZoneFormatDto =
    ZoneFormatDto(
        id = id,
        name = name,
        description = description,
        type = type,
        capacityCap = capacityCap,
        durationMin = durationMin,
    )

fun InstructorEntity.toDto(): InstructorDto =
    InstructorDto(id = id, name = name)
