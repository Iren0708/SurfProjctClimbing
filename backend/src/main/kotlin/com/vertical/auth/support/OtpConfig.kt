package com.vertical.auth.support

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import java.security.SecureRandom

@Configuration
class OtpConfig {

    @Bean
    @Profile("test | integration | docker")
    fun fixedOtpCodeGenerator(): OtpCodeGenerator =
        OtpCodeGenerator { "1234" }

    @Bean
    @Profile("!test & !integration & !docker")
    fun randomOtpCodeGenerator(): OtpCodeGenerator =
        OtpCodeGenerator {
            val value = SecureRandom().nextInt(10_000)
            "%04d".format(value)
        }
}
