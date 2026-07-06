package com.vertical.auth.api

import com.vertical.auth.dto.RefreshTokenRequest
import com.vertical.auth.dto.RequestCodeRequest
import com.vertical.auth.dto.RequestCodeResponse
import com.vertical.auth.dto.VerifyCodeRequest
import com.vertical.auth.dto.VerifyCodeResponse
import com.vertical.auth.security.ClientPrincipal
import com.vertical.auth.service.AuthService
import com.vertical.config.OpenApiConfig
import com.vertical.auth.service.OtpService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "Auth", description = "Аутентификация по телефону и OTP")
@RestController
@RequestMapping("/v1/auth")
class AuthController(
    private val otpService: OtpService,
    private val authService: AuthService,
) {

    @Operation(operationId = "requestAuthCode", summary = "Запросить код подтверждения (OTP)")
    @PostMapping("/request-code")
    fun requestAuthCode(@Valid @RequestBody request: RequestCodeRequest): RequestCodeResponse =
        otpService.requestLoginCode(request.phone)

    @Operation(operationId = "verifyAuthCode", summary = "Подтвердить код и получить токены")
    @PostMapping("/verify-code")
    fun verifyAuthCode(@Valid @RequestBody request: VerifyCodeRequest): VerifyCodeResponse =
        authService.verifyAuthCode(request.phone, request.code)

    @Operation(operationId = "refreshToken", summary = "Обновить access token")
    @PostMapping("/refresh")
    fun refreshToken(@Valid @RequestBody request: RefreshTokenRequest) =
        authService.refreshToken(request.refreshToken)

    @Operation(
        operationId = "logout",
        summary = "Выйти из аккаунта",
        security = [SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)],
    )
    @PostMapping("/logout")
    fun logout(@AuthenticationPrincipal principal: ClientPrincipal): ResponseEntity<Void> {
        authService.logout(principal)
        return ResponseEntity.noContent().build()
    }
}
