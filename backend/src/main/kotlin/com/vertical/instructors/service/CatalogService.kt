package com.vertical.instructors.service

import com.vertical.common.pagination.PageParams
import com.vertical.common.pagination.PaginationMeta
import com.vertical.common.pagination.toPageable
import com.vertical.instructors.dto.InstructorDto
import com.vertical.instructors.dto.InstructorListResponse
import com.vertical.instructors.dto.ZoneFormatDto
import com.vertical.instructors.dto.ZoneFormatListResponse
import com.vertical.instructors.dto.toDto
import com.vertical.instructors.repository.InstructorRepository
import com.vertical.instructors.repository.ZoneFormatRepository
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class CatalogService(
    private val zoneFormatRepository: ZoneFormatRepository,
    private val instructorRepository: InstructorRepository,
) {

    @Transactional(readOnly = true)
    fun listZoneFormats(page: PageParams): ZoneFormatListResponse {
        val pageable = page.toPageable(Sort.by("name").ascending())
        val result = zoneFormatRepository.findAll(pageable)
        return ZoneFormatListResponse(
            items = result.content.map { it.toDto() },
            meta = PaginationMeta(
                limit = page.limit,
                offset = page.offset,
                total = result.totalElements.toInt(),
            ),
        )
    }

    @Transactional(readOnly = true)
    fun listInstructors(page: PageParams): InstructorListResponse {
        val pageable = page.toPageable(Sort.by("name").ascending())
        val result = instructorRepository.findAll(pageable)
        return InstructorListResponse(
            items = result.content.map { it.toDto() },
            meta = PaginationMeta(
                limit = page.limit,
                offset = page.offset,
                total = result.totalElements.toInt(),
            ),
        )
    }

    @Transactional(readOnly = true)
    fun getZoneFormat(id: java.util.UUID): ZoneFormatDto? =
        zoneFormatRepository.findById(id).map { it.toDto() }.orElse(null)

    @Transactional(readOnly = true)
    fun getInstructor(id: java.util.UUID): InstructorDto? =
        instructorRepository.findById(id).map { it.toDto() }.orElse(null)
}
