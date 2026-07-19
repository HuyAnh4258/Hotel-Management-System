package com.hotel.hms.modules.booking_management.dto;

import java.util.List;

public record HomepageResponse(
        List<RoomTypeSummary> roomTypes,
        List<RoomSummary> availableRooms,
        List<BookingSummary> recentBookings
) {
}