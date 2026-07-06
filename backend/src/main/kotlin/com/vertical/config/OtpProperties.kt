package com.vertical.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "vertical.otp")
data class OtpProperties(
    val ttlSeconds: Long = 300,
    val resendAfterSeconds: Long = 60,
    val maxVerifyAttempts: Int = 5,
    val maxRequestsPerWindow: Int = 10,
    val requestWindowSeconds: Long = 3600,
)
