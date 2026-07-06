package com.vertical.slots.repository

import com.vertical.instructors.entity.ZoneFormatEntity
import com.vertical.slots.entity.SlotEntity
import jakarta.persistence.criteria.Predicate
import org.springframework.data.jpa.domain.Specification
import java.time.Instant
import java.util.UUID

object SlotSpecifications {

    fun withFilters(
        dateFrom: Instant,
        dateTo: Instant,
        zoneFormatTypes: List<String>?,
        instructorIds: List<UUID>?,
        onlyAvailable: Boolean,
    ): Specification<SlotEntity> =
        Specification { root, query, cb ->
            val predicates = mutableListOf<Predicate>()
            val criteriaQuery = requireNotNull(query)

            predicates += cb.greaterThanOrEqualTo(root.get("startAt"), dateFrom)
            predicates += cb.lessThanOrEqualTo(root.get("startAt"), dateTo)

            if (onlyAvailable) {
                predicates += cb.greaterThan(root.get("freeSeats"), 0)
            }

            if (!zoneFormatTypes.isNullOrEmpty()) {
                val subquery = criteriaQuery.subquery(UUID::class.java)
                val zoneFormat = subquery.from(ZoneFormatEntity::class.java)
                subquery.select(zoneFormat.get("id")).where(
                    zoneFormat.get<String>("type").`in`(zoneFormatTypes),
                )
                predicates += root.get<UUID>("zoneFormatId").`in`(subquery)
            }

            if (!instructorIds.isNullOrEmpty()) {
                predicates += root.get<UUID>("instructorId").`in`(instructorIds)
            }

            cb.and(*predicates.toTypedArray())
        }
}
