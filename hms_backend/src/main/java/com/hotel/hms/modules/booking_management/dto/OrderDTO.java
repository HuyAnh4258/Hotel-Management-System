package com.hotel.hms.dto;

import java.math.BigDecimal;

public record OrderDTO(
        String orderId,
        String employeeId,
        String bookingId,
        String guestName,
        BigDecimal totalAmount,
        String status,
        String orderedAt
) {
}
