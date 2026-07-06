package com.vertical.auth.support

fun interface OtpCodeGenerator {
    fun generate(): String
}
