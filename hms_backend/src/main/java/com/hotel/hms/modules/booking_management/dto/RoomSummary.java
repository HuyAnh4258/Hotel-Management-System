package com.hotel.hms.modules.booking_management.dto;

public record RoomSummary(
        String roomId,
        String roomName,
        Integer floorNumber,
        String status,
        String description,
        RoomTypeSummary roomType
) {
}