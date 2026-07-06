package com.vertical.config

import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.security.SecurityScheme
import io.swagger.v3.oas.models.servers.Server
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {

    @Bean
    fun verticalOpenApi(): OpenAPI =
        OpenAPI()
            .info(
                Info()
                    .title("Скалодром «Вертикаль» API")
                    .description("Клиентский REST API для записи на групповые тренировки (MVP).")
                    .version("1.0.0"),
            )
            .addServersItem(
                Server()
                    .url("http://localhost:8080")
                    .description("Local development"),
            )
            .components(
                Components()
                    .addSecuritySchemes(
                        BEARER_AUTH,
                        SecurityScheme()
                            .type(SecurityScheme.Type.HTTP)
                            .scheme("bearer")
                            .bearerFormat("JWT")
                            .description("Access token из verifyAuthCode / refreshToken"),
                    ),
            )

    companion object {
        const val BEARER_AUTH = "bearerAuth"
    }
}
