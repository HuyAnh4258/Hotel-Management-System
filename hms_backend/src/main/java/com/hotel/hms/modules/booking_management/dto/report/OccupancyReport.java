package com.hotel.hms.modules.booking_management.dto.report;

public record OccupancyReport(
        int totalRooms,
        int occupiedRooms,
        int maintenanceRooms,
        int availableRooms,
        double occupancyRate
) {
}
