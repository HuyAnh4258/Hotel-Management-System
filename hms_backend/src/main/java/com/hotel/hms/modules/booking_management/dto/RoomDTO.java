package com.hotel.hms.modules.booking_management.dto;

public record RoomDTO(
        String roomId,
        String roomName,
        String roomTypeName,
        int floorNumber,
        String status,
        String description
) {
}
