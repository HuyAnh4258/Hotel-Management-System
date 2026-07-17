package com.hotel.hms.dto;

import java.util.List;

public record HomepageResponse(
        List<RoomTypeSummary> roomTypes,
        List<RoomSummary> availableRooms,
        List<BookingSummary> recentBookings
) {
}