package com.vertical.profile.api

import com.vertical.auth.security.ClientPrincipal
import com.vertical.config.OpenApiConfig
import com.vertical.profile.dto.ClientDto
import com.vertical.profile.dto.UpdateProfileRequest
import com.vertical.profile.service.ProfileService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "Profile", description = "Профиль клиента")
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH)
@RestController
@RequestMapping("/v1/profile")
class ProfileController(
    private val profileService: ProfileService,
) {

    @Operation(operationId = "getProfile", summary = "Получить профиль")
    @GetMapping
    fun getProfile(@AuthenticationPrincipal principal: ClientPrincipal): ClientDto =
        profileService.getProfile(principal.clientId)

    @Operation(operationId = "updateProfile", summary = "Обновить профиль")
    @PatchMapping
    fun updateProfile(
        @AuthenticationPrincipal principal: ClientPrincipal,
        @Valid @RequestBody request: UpdateProfileRequest,
    ): ClientDto = profileService.updateProfile(principal.clientId, request.name)

    @Operation(operationId = "deleteAccount", summary = "Удалить аккаунт")
    @DeleteMapping
    fun deleteAccount(@AuthenticationPrincipal principal: ClientPrincipal): ResponseEntity<Void> {
        profileService.deleteAccount(principal.clientId)
        return ResponseEntity.noContent().build()
    }
}
