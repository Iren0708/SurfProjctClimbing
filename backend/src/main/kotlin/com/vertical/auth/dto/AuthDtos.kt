package com.vertical.auth.dto

import com.fasterxml.jackson.annotation.JsonInclude
import com.vertical.profile.dto.ClientDto
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern

data class RequestCodeRequest(
    @field:NotBlank
    @field:Pattern(regexp = "^\\+[1-9]\\d{1,14}$")
    val phone: String,
)

data class RequestCodeResponse(
    val ttlSeconds: Long,
    val resendAfterSeconds: Long,
)

data class VerifyCodeRequest(
    @field:NotBlank
    @field:Pattern(regexp = "^\\+[1-9]\\d{1,14}$")
    val phone: String,
    @field:NotBlank
    @field:Pattern(regexp = "^\\d{4,6}$")
    val code: String,
)

@JsonInclude(JsonInclude.Include.NON_NULL)
data class VerifyCodeResponse(
    val tokens: TokenPairDto,
    val client: ClientDto,
    val isNew: Boolean,
)

data class RefreshTokenRequest(
    @field:NotBlank
    val refreshToken: String,
)

data class TokenPairDto(
    val accessToken: String,
    val refreshToken: String,
    val tokenType: String = "Bearer",
    val expiresIn: Long,
)
