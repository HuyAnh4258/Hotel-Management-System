package com.hotel.hms.dto;

public record RoomDTO(
        String roomId,
        String roomName,
        String roomTypeName,
        int floorNumber,
        String status,
        String description
) {
}
