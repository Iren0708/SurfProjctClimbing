package com.vertical.auth.security

import com.vertical.auth.repository.ClientRepository
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
class JwtAuthenticationFilter(
    private val jwtService: JwtService,
    private val clientRepository: ClientRepository,
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val authorization = request.getHeader(HttpHeaders.AUTHORIZATION)
        if (authorization != null && authorization.startsWith(BEARER_PREFIX)) {
            val token = authorization.removePrefix(BEARER_PREFIX).trim()
            if (token.isNotEmpty()) {
                try {
                    val principal = jwtService.parseAccessToken(token)
                    if (clientRepository.findByIdAndDeletedAtIsNull(principal.clientId) == null) {
                        SecurityContextHolder.clearContext()
                    } else {
                        val authentication = UsernamePasswordAuthenticationToken(
                            principal,
                            null,
                            emptyList(),
                        )
                        SecurityContextHolder.getContext().authentication = authentication
                    }
                } catch (_: Exception) {
                    SecurityContextHolder.clearContext()
                }
            }
        }
        filterChain.doFilter(request, response)
    }

    companion object {
        private const val BEARER_PREFIX = "Bearer "
    }
}
