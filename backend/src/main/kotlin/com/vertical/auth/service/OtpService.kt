package com.vertical.auth.service

import com.vertical.auth.dto.RequestCodeResponse
import com.vertical.auth.entity.OtpCodeEntity
import com.vertical.auth.repository.OtpCodeRepository
import com.vertical.auth.support.OtpCodeGenerator
import com.vertical.auth.support.TokenHasher
import com.vertical.common.exception.TooManyRequestsException
import com.vertical.config.OtpProperties
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock

@Service
class OtpService(
    private val otpCodeRepository: OtpCodeRepository,
    private val otpProperties: OtpProperties,
    private val otpCodeGenerator: OtpCodeGenerator,
    private val clock: Clock,
) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Transactional
    fun requestLoginCode(phone: String): RequestCodeResponse {
        enforceRequestRateLimit(phone)
        enforceResendCooldown(phone)

        val now = clock.instant()
        val code = otpCodeGenerator.generate()
        otpCodeRepository.save(
            OtpCodeEntity(
                phone = phone,
                purpose = PURPOSE_LOGIN,
                codeHash = TokenHasher.sha256(code),
                createdAt = now,
                expiresAt = now.plusSeconds(otpProperties.ttlSeconds),
            ),
        )
        log.info("OTP for {}: {} (mock SMS)", phone, code)

        return RequestCodeResponse(
            ttlSeconds = otpProperties.ttlSeconds,
            resendAfterSeconds = otpProperties.resendAfterSeconds,
        )
    }

    @Transactional
    fun verifyLoginCode(phone: String, code: String): OtpCodeEntity {
        val otp = otpCodeRepository.findFirstByPhoneAndPurposeAndConsumedAtIsNullOrderByCreatedAtDesc(
            phone,
            PURPOSE_LOGIN,
        ) ?: throw com.vertical.common.exception.InvalidCodeException()

        val now = clock.instant()
        if (otp.expiresAt.isBefore(now) || otp.attemptCount >= otpProperties.maxVerifyAttempts) {
            throw com.vertical.common.exception.InvalidCodeException()
        }

        if (otp.codeHash != TokenHasher.sha256(code)) {
            otp.attemptCount += 1
            otpCodeRepository.save(otp)
            if (otp.attemptCount >= otpProperties.maxVerifyAttempts) {
                throw TooManyRequestsException("Слишком много попыток. Запросите новый код.")
            }
            throw com.vertical.common.exception.InvalidCodeException()
        }

        otp.consumedAt = now
        otpCodeRepository.save(otp)
        return otp
    }

    private fun enforceRequestRateLimit(phone: String) {
        val windowStart = clock.instant().minusSeconds(otpProperties.requestWindowSeconds)
        val count = otpCodeRepository.countByPhoneAndPurposeAndCreatedAtAfter(phone, PURPOSE_LOGIN, windowStart)
        if (count >= otpProperties.maxRequestsPerWindow) {
            throw TooManyRequestsException()
        }
    }

    private fun enforceResendCooldown(phone: String) {
        val latest = otpCodeRepository.findFirstByPhoneAndPurposeAndConsumedAtIsNullOrderByCreatedAtDesc(
            phone,
            PURPOSE_LOGIN,
        ) ?: return
        val resendAllowedAt = latest.createdAt.plusSeconds(otpProperties.resendAfterSeconds)
        if (clock.instant().isBefore(resendAllowedAt)) {
            throw TooManyRequestsException()
        }
    }

    companion object {
        const val PURPOSE_LOGIN = "login"
    }
}
