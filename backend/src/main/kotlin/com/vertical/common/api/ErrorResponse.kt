package com.vertical.common.api

import com.fasterxml.jackson.annotation.JsonInclude
import com.vertical.common.exception.ErrorCode
import com.vertical.common.exception.ErrorDetails

@JsonInclude(JsonInclude.Include.NON_NULL)
data class ErrorResponse(
    val code: String,
    val message: String,
    val details: ErrorDetails? = null,
) {
    companion object {
        fun of(code: ErrorCode, message: String, details: ErrorDetails? = null): ErrorResponse =
            ErrorResponse(code = code.wireValue, message = message, details = details)
    }
}
