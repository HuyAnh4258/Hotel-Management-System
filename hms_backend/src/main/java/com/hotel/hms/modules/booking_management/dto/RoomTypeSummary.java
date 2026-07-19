package com.hotel.hms.modules.booking_management.dto;

import java.math.BigDecimal;

public record RoomTypeSummary(
        String roomTypeId,
        String typeName,
        String description,
        BigDecimal basePrice,
        Integer maxOccupancy,
        String imageUrl
) {
}
