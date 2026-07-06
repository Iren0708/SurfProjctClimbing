package com.vertical.bookings.repository

import com.vertical.bookings.entity.BookingEntity
import com.vertical.slots.entity.SlotEntity
import jakarta.persistence.criteria.JoinType
import jakarta.persistence.criteria.Predicate
import org.springframework.data.jpa.domain.Specification
import java.time.Instant
import java.util.UUID

object BookingSpecifications {

    fun forClient(
        clientId: UUID,
        statuses: List<String>?,
    ): Specification<BookingEntity> =
        Specification { root, query, cb ->
            val predicates = mutableListOf<Predicate>()

            predicates += cb.equal(root.get<UUID>("clientId"), clientId)

            if (!statuses.isNullOrEmpty()) {
                predicates += root.get<String>("status").`in`(statuses)
            }

            if (query != null && query.resultType != Long::class.java && query.resultType != Long::class.javaObjectType) {
                val slotJoin = root.join<BookingEntity, SlotEntity>("slot", JoinType.INNER)
                query.orderBy(cb.desc(slotJoin.get<Instant>("startAt")))
            }

            cb.and(*predicates.toTypedArray())
        }
}
