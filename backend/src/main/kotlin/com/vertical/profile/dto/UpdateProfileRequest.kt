package com.vertical.profile.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class UpdateProfileRequest(
    @field:NotBlank
    @field:Size(min = 1, max = 100)
    val name: String,
)
