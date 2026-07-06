package com.vertical.auth.security

import java.util.UUID

data class ClientPrincipal(
    val clientId: UUID,
    val sessionId: UUID? = null,
)
