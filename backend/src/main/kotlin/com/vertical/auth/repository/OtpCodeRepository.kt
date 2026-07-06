package com.vertical.auth.repository

import com.vertical.auth.entity.OtpCodeEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import java.util.UUID

interface OtpCodeRepository : JpaRepository<OtpCodeEntity, UUID> {

    fun findFirstByPhoneAndPurposeAndConsumedAtIsNullOrderByCreatedAtDesc(
        phone: String,
        purpose: String,
    ): OtpCodeEntity?

    fun countByPhoneAndPurposeAndCreatedAtAfter(
        phone: String,
        purpose: String,
        createdAt: java.time.Instant,
    ): Long
}
