package com.vertical.common.exception

/**
 * Machine-readable error codes from [01-analysis/api/common/models.yaml].
 */
enum class ErrorCode {
    SLOT_FULL,
    RENTAL_UNAVAILABLE,
    DOUBLE_BOOKING,
    SLOT_CANCELLED,
    SLOT_STARTED,
    ALREADY_CANCELLED,
    INVALID_CODE,
    IDEMPOTENCY_KEY_CONFLICT,
    BAD_REQUEST,
    UNAUTHORIZED,
    FORBIDDEN,
    NOT_FOUND,
    TOO_MANY_REQUESTS,
    INTERNAL_ERROR,
    ;

    val wireValue: String
        get() = name.lowercase()
}
