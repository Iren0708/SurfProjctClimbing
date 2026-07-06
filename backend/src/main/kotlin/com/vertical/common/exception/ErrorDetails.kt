package com.vertical.common.exception

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonProperty

@JsonInclude(JsonInclude.Include.NON_NULL)
data class ErrorDetails(
    @JsonProperty("available_seats")
    val availableSeats: Int? = null,
    @JsonProperty("available_rental_equipment")
    val availableRentalEquipment: Int? = null,
)
