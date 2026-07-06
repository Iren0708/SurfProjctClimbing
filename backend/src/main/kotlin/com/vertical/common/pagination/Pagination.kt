package com.vertical.common.pagination

data class PaginationMeta(
    val limit: Int,
    val offset: Int,
    val total: Int,
)

data class PageParams(
    val limit: Int = DEFAULT_LIMIT,
    val offset: Int = DEFAULT_OFFSET,
) {
    init {
        require(limit in MIN_LIMIT..MAX_LIMIT) { "limit must be between $MIN_LIMIT and $MAX_LIMIT" }
        require(offset >= 0) { "offset must be non-negative" }
    }

    companion object {
        const val DEFAULT_LIMIT = 20
        const val DEFAULT_OFFSET = 0
        const val MIN_LIMIT = 1
        const val MAX_LIMIT = 100
    }
}
