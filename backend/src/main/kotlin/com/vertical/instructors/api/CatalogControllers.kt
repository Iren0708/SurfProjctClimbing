package com.vertical.instructors.api

import com.vertical.common.pagination.PageParams
import com.vertical.config.OpenApiConfig
import com.vertical.instructors.dto.InstructorListResponse
import com.vertical.instructors.dto.ZoneFormatListResponse
import com.vertical.instructors.service.CatalogService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@Tag(name = "Instructors", description = "Справочники зон/форматов и инструкторов")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@RestController
@RequestMapping("/v1/zone-formats")
class ZoneFormatsController(
    private val catalogService: CatalogService,
) {

    @Operation(operationId = "listZoneFormats", summary = "Список зон и форматов")
    @GetMapping
    fun listZoneFormats(
        @RequestParam(defaultValue = PageParams.DEFAULT_LIMIT.toString()) limit: Int,
        @RequestParam(defaultValue = PageParams.DEFAULT_OFFSET.toString()) offset: Int,
    ): ZoneFormatListResponse =
        catalogService.listZoneFormats(PageParams(limit = limit, offset = offset))
}

@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@RestController
@RequestMapping("/v1/instructors")
class InstructorsController(
    private val catalogService: CatalogService,
) {

    @Operation(operationId = "listInstructors", summary = "Список инструкторов")
    @GetMapping
    fun listInstructors(
        @RequestParam(defaultValue = PageParams.DEFAULT_LIMIT.toString()) limit: Int,
        @RequestParam(defaultValue = PageParams.DEFAULT_OFFSET.toString()) offset: Int,
    ): InstructorListResponse =
        catalogService.listInstructors(PageParams(limit = limit, offset = offset))
}
