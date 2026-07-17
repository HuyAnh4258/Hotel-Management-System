package com.hotel.hms.dto;

public record RoomSummary(
        String roomId,
        String roomName,
        Integer floorNumber,
        String status,
        String description,
        RoomTypeSummary roomType
) {
}