package com.vertical.common.exception

import org.springframework.http.HttpStatus

open class ApiException(
    val errorCode: ErrorCode,
    override val message: String,
    val details: ErrorDetails? = null,
    val httpStatus: HttpStatus,
) : RuntimeException(message)

class BadRequestException(
    message: String = "Неверные параметры запроса. Проверьте корректность переданных значений.",
    details: ErrorDetails? = null,
) : ApiException(ErrorCode.BAD_REQUEST, message, details, HttpStatus.BAD_REQUEST)

class InvalidCodeException(
    message: String = "Неверный или истёкший код подтверждения.",
) : ApiException(ErrorCode.INVALID_CODE, message, null, HttpStatus.BAD_REQUEST)

class UnauthorizedException(
    message: String = "Требуется авторизация. Передайте действительный токен в заголовке Authorization.",
) : ApiException(ErrorCode.UNAUTHORIZED, message, null, HttpStatus.UNAUTHORIZED)

class ForbiddenException(
    message: String = "Доступ запрещён. Вы не можете обращаться к данным другого клиента.",
) : ApiException(ErrorCode.FORBIDDEN, message, null, HttpStatus.FORBIDDEN)

class NotFoundException(
    message: String = "Запрашиваемый ресурс не найден.",
) : ApiException(ErrorCode.NOT_FOUND, message, null, HttpStatus.NOT_FOUND)

class ConflictException(
    errorCode: ErrorCode,
    message: String,
    details: ErrorDetails? = null,
) : ApiException(errorCode, message, details, HttpStatus.CONFLICT)

class GoneException(
    message: String = "Тренировка отменена скалодромом и недоступна для записи.",
) : ApiException(ErrorCode.SLOT_CANCELLED, message, null, HttpStatus.GONE)

class UnprocessableEntityException(
    errorCode: ErrorCode = ErrorCode.SLOT_STARTED,
    message: String,
) : ApiException(errorCode, message, null, HttpStatus.UNPROCESSABLE_ENTITY)

class TooManyRequestsException(
    message: String = "Слишком много запросов. Повторите попытку позже.",
) : ApiException(ErrorCode.TOO_MANY_REQUESTS, message, null, HttpStatus.TOO_MANY_REQUESTS)
