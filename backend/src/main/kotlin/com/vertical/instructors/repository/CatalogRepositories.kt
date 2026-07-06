package com.vertical.instructors.repository

import com.vertical.instructors.entity.InstructorEntity
import com.vertical.instructors.entity.ZoneFormatEntity
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface ZoneFormatRepository : JpaRepository<ZoneFormatEntity, UUID>

interface InstructorRepository : JpaRepository<InstructorEntity, UUID>
