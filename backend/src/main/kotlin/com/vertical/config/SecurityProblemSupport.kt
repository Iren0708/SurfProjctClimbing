package com.vertical.config

import com.fasterxml.jackson.databind.ObjectMapper
import com.vertical.common.api.ErrorResponse
import com.vertical.common.exception.ErrorCode
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.core.AuthenticationException
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.stereotype.Component

@Component
class BearerAuthenticationEntryPoint(
    private val objectMapper: ObjectMapper,
) : AuthenticationEntryPoint {

    override fun commence(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authException: AuthenticationException,
    ) {
        writeError(response, objectMapper, HttpStatus.UNAUTHORIZED)
    }
}

@Component
class BearerAccessDeniedHandler(
    private val objectMapper: ObjectMapper,
) : AccessDeniedHandler {

    override fun handle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        accessDeniedException: AccessDeniedException,
    ) {
        writeError(response, objectMapper, HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN)
    }
}

private fun writeError(
    response: HttpServletResponse,
    objectMapper: ObjectMapper,
    status: HttpStatus,
    code: ErrorCode = ErrorCode.UNAUTHORIZED,
) {
    response.status = status.value()
    response.contentType = MediaType.APPLICATION_JSON_VALUE
    val body = when (code) {
        ErrorCode.FORBIDDEN -> ErrorResponse.of(
            ErrorCode.FORBIDDEN,
            "Доступ запрещён. Вы не можете обращаться к данным другого клиента.",
        )
        else -> ErrorResponse.of(
            ErrorCode.UNAUTHORIZED,
            "Требуется авторизация. Передайте действительный токен в заголовке Authorization.",
        )
    }
    response.writer.write(objectMapper.writeValueAsString(body))
}
