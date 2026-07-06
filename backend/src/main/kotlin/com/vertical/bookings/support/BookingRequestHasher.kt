package com.vertical.bookings.support

import com.vertical.auth.support.TokenHasher
import java.util.UUID

object BookingRequestHasher {
    fun hash(slotId: UUID, equipment: String): String =
        TokenHasher.sha256("$slotId|$equipment")
}
