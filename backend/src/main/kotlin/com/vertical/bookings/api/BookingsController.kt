package com.vertical.bookings.api

import com.vertical.auth.security.ClientPrincipal
import com.vertical.bookings.dto.BookingDto
import com.vertical.bookings.dto.BookingListResponse
import com.vertical.bookings.dto.CreateBookingRequest
import com.vertical.bookings.dto.CreateBookingResponse
import com.vertical.bookings.service.BookingService
import com.vertical.common.pagination.PageParams
import com.vertical.config.OpenApiConfig
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.enums.ParameterIn
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@Tag(name = "Bookings", description = "Бронирования")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@RestController
@RequestMapping("/v1/bookings")
class BookingsController(
    private val bookingService: BookingService,
) {

    @Operation(operationId = "createBooking", summary = "Создать бронь")
    @PostMapping
    fun createBooking(
        @AuthenticationPrincipal principal: ClientPrincipal,
        @Parameter(
            name = "Idempotency-Key",
            `in` = ParameterIn.HEADER,
            required = true,
            description = "UUID ключ идемпотентности",
        )
        @RequestHeader("Idempotency-Key") idempotencyKey: UUID,
        @Valid @RequestBody request: CreateBookingRequest,
    ): ResponseEntity<CreateBookingResponse> {
        val response = bookingService.createBooking(
            clientId = principal.clientId,
            idempotencyKey = idempotencyKey,
            request = request,
        )
        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }

    @Operation(operationId = "listBookings", summary = "Мои брони")
    @GetMapping
    fun listBookings(
        @AuthenticationPrincipal principal: ClientPrincipal,
        @RequestParam(required = false) status: List<String>?,
        @RequestParam(defaultValue = PageParams.DEFAULT_LIMIT.toString()) limit: Int,
        @RequestParam(defaultValue = PageParams.DEFAULT_OFFSET.toString()) offset: Int,
    ): BookingListResponse =
        bookingService.listBookings(
            clientId = principal.clientId,
            statuses = status,
            page = PageParams(limit = limit, offset = offset),
        )

    @Operation(operationId = "getBooking", summary = "Детали брони")
    @GetMapping("/{bookingId}")
    fun getBooking(
        @AuthenticationPrincipal principal: ClientPrincipal,
        @PathVariable bookingId: UUID,
    ): BookingDto =
        bookingService.getBooking(
            clientId = principal.clientId,
            bookingId = bookingId,
        )

    @Operation(operationId = "cancelBooking", summary = "Отменить бронь")
    @PostMapping("/{bookingId}/cancel")
    fun cancelBooking(
        @AuthenticationPrincipal principal: ClientPrincipal,
        @PathVariable bookingId: UUID,
    ): BookingDto =
        bookingService.cancelBooking(
            clientId = principal.clientId,
            bookingId = bookingId,
        )
}
