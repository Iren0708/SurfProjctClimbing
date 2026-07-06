package com.vertical.common.pagination

import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort

class OffsetLimitPageRequest(
    private val offset: Int,
    private val limit: Int,
    private val sort: Sort = Sort.unsorted(),
) : Pageable {

    override fun getPageNumber(): Int = offset / limit

    override fun getPageSize(): Int = limit

    override fun getOffset(): Long = offset.toLong()

    override fun getSort(): Sort = sort

    override fun next(): Pageable = OffsetLimitPageRequest(offset + limit, limit, sort)

    override fun previousOrFirst(): Pageable {
        val newOffset = (offset - limit).coerceAtLeast(0)
        return OffsetLimitPageRequest(newOffset, limit, sort)
    }

    override fun first(): Pageable = OffsetLimitPageRequest(0, limit, sort)

    override fun withPage(pageNumber: Int): Pageable =
        OffsetLimitPageRequest(pageNumber * limit, limit, sort)

    override fun hasPrevious(): Boolean = offset > 0
}

fun PageParams.toPageable(sort: Sort = Sort.unsorted()): Pageable =
    OffsetLimitPageRequest(offset, limit, sort)
