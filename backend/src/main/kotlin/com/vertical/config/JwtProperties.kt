package com.vertical.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "vertical.jwt")
data class JwtProperties(
    val secret: String,
    val accessTokenTtlSeconds: Long = 900,
    val refreshTokenTtlSeconds: Long = 2_592_000,
)
