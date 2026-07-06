package com.vertical.bookings.dto

import com.fasterxml.jackson.annotation.JsonInclude
import com.vertical.common.pagination.PaginationMeta
import com.vertical.slots.dto.SlotDto
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Pattern
import java.time.Instant
import java.util.UUID

data class CreateBookingRequest(
    @field:NotNull
    val slotId: UUID,
    @field:NotBlank
    @field:Pattern(regexp = "^(own|rental)$")
    val equipment: String,
)

@JsonInclude(JsonInclude.Include.NON_NULL)
data class BookingDto(
    val id: UUID,
    val slotId: UUID,
    val clientId: UUID,
    val equipment: String,
    val status: String,
    val priceTotal: Int,
    val createdAt: Instant,
    val cancelledAt: Instant? = null,
    val cancellationReason: String? = null,
    val slot: SlotDto,
)

@JsonInclude(JsonInclude.Include.NON_NULL)
data class BookingSummaryDto(
    val id: UUID,
    val slotId: UUID,
    val equipment: String,
    val status: String,
    val priceTotal: Int,
    val createdAt: Instant,
    val cancelledAt: Instant? = null,
    val cancellationReason: String? = null,
    val slot: SlotDto,
)

data class BookingListResponse(
    val items: List<BookingSummaryDto>,
    val meta: PaginationMeta,
)

@JsonInclude(JsonInclude.Include.NON_NULL)
data class CreateBookingResponse(
    val id: UUID,
    val slotId: UUID,
    val clientId: UUID,
    val equipment: String,
    val status: String,
    val priceTotal: Int,
    val createdAt: Instant,
    val cancelledAt: Instant? = null,
    val cancellationReason: String? = null,
    val slot: SlotDto,
    val isFirstBooking: Boolean,
    val reminderHours: List<Int> = REMINDER_HOURS,
) {
    companion object {
        val REMINDER_HOURS = listOf(24, 2)
    }
}
