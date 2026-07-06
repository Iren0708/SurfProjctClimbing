package com.vertical.slots.dto

import com.vertical.common.pagination.PaginationMeta
import com.vertical.instructors.dto.InstructorDto
import com.vertical.instructors.dto.ZoneFormatDto
import java.time.Instant
import java.util.UUID

data class SlotDto(
    val id: UUID,
    val startAt: Instant,
    val zoneFormat: ZoneFormatDto,
    val instructorInfo: InstructorDto,
    val totalSeats: Int,
    val freeSeats: Int,
    val freeRentalEquipment: Int,
    val price: Int,
    val rentalPrice: Int,
    val status: String,
)

typealias SlotSummaryDto = SlotDto

data class SlotListResponse(
    val items: List<SlotSummaryDto>,
    val meta: PaginationMeta,
)
