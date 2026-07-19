package com.hotel.hms.dto;

import java.math.BigDecimal;

public record RoomTypeSummary(
        String roomTypeId,
        String typeName,
        String description,
        BigDecimal basePrice,
        Integer maxOccupancy
) {
}