package com.hotel.hms.dto;

import java.math.BigDecimal;
import java.util.List;

public record BookingSummary(
        String bookingId,
        String guestName,
        String phone,
        String expectedCheckin,
        String expectedCheckout,
        String status,
        BigDecimal totalAmount,
        List<String> rooms
) {
    public boolean canCheckIn(String today) {
        return expectedCheckin != null && expectedCheckin.startsWith(today) && "PENDING".equalsIgnoreCase(status);
    }

    public boolean canCheckOut(String today) {
        return expectedCheckout != null && expectedCheckout.startsWith(today) && "CHECKED_IN".equalsIgnoreCase(status);
    }
}
