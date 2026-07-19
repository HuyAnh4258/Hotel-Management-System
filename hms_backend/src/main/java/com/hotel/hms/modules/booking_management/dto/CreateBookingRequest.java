package com.hotel.hms.modules.booking_management.dto;

import java.time.LocalDate;
import java.util.List;

public record CreateBookingRequest(
        String guestName,
        String email,
        String phone,
        String userId,
        LocalDate expectedCheckin,
        LocalDate expectedCheckout,
        List<String> roomIds,
        String voucherCode,
        Integer guests
) {
}
