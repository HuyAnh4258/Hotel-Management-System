package com.hotel.hms.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record ServiceOrderLineRequest(
        @NotBlank String serviceId,
        @Min(1) int quantity
) {
}
