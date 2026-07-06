package com.vertical.bookings.service

import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.Instant
import java.time.temporal.ChronoUnit

class BookingCancellationPolicyTest {

    @Test
    fun `exactly 2 hours before start is early cancel`() {
        val now = Instant.parse("2026-07-06T10:00:00Z")
        val startAt = now.plus(2, ChronoUnit.HOURS)

        assertTrue(isEarlyCancel(now, startAt))
    }

    @Test
    fun `one second before 2 hour boundary is late cancel`() {
        val now = Instant.parse("2026-07-06T10:00:00Z")
        val startAt = now.plus(2, ChronoUnit.HOURS).minus(1, ChronoUnit.SECONDS)

        assertFalse(isEarlyCancel(now, startAt))
    }

    @Test
    fun `more than 2 hours before start is early cancel`() {
        val now = Instant.parse("2026-07-06T10:00:00Z")
        val startAt = now.plus(3, ChronoUnit.HOURS)

        assertTrue(isEarlyCancel(now, startAt))
    }

    private fun isEarlyCancel(now: Instant, startAt: Instant): Boolean =
        !now.isAfter(startAt.minus(2, ChronoUnit.HOURS))
}
