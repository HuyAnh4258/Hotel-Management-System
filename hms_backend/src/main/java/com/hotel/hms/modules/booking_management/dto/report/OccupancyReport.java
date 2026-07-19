package com.hotel.hms.dto.report;

public record OccupancyReport(
        int totalRooms,
        int occupiedRooms,
        int maintenanceRooms,
        int availableRooms,
        double occupancyRate
) {
}
