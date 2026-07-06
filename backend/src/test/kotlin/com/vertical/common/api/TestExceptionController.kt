package com.vertical.common.api

import com.vertical.common.exception.NotFoundException
import com.vertical.common.exception.UnauthorizedException
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.context.annotation.Profile
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Profile("test")
@RestController
@RequestMapping("/test-errors")
class TestExceptionController {

    @GetMapping("/unauthorized")
    fun unauthorized(): Nothing = throw UnauthorizedException()

    @GetMapping("/not-found")
    fun notFound(): Nothing = throw NotFoundException()

    @PostMapping("/bad-request")
    fun badRequest(@Valid @RequestBody body: SampleRequest): Map<String, String> =
        mapOf("status" to "ok")

    data class SampleRequest(
        @field:NotBlank val name: String,
    )
}
