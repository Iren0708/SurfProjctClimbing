package com.vertical.slots.api

import com.vertical.common.pagination.PageParams
import com.vertical.config.OpenApiConfig
import com.vertical.slots.dto.SlotDto
import com.vertical.slots.dto.SlotListResponse
import com.vertical.slots.service.SlotsService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

@Tag(name = "Slots", description = "Слоты тренировок")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@RestController
@RequestMapping("/v1/slots")
class SlotsController(
    private val slotsService: SlotsService,
) {

    @Operation(operationId = "listSlots", summary = "Список слотов")
    @GetMapping
    fun listSlots(
        @RequestParam(name = "date_from", required = false)
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        dateFrom: Instant?,
        @RequestParam(name = "date_to", required = false)
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        dateTo: Instant?,
        @RequestParam(name = "zone_format_type", required = false)
        zoneFormatTypes: List<String>?,
        @RequestParam(name = "instructor_id", required = false)
        instructorIds: List<UUID>?,
        @RequestParam(name = "only_available", defaultValue = "false")
        onlyAvailable: Boolean,
        @RequestParam(defaultValue = PageParams.DEFAULT_LIMIT.toString()) limit: Int,
        @RequestParam(defaultValue = PageParams.DEFAULT_OFFSET.toString()) offset: Int,
    ): SlotListResponse =
        slotsService.listSlots(
            dateFrom = dateFrom,
            dateTo = dateTo,
            zoneFormatTypes = zoneFormatTypes,
            instructorIds = instructorIds,
            onlyAvailable = onlyAvailable,
            page = PageParams(limit = limit, offset = offset),
        )

    @Operation(operationId = "getSlot", summary = "Карточка слота")
    @GetMapping("/{slotId}")
    fun getSlot(@PathVariable slotId: UUID): SlotDto =
        slotsService.getSlot(slotId)
}
