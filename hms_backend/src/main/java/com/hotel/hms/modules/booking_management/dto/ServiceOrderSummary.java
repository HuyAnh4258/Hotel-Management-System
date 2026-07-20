package com.hotel.hms.modules.booking_management.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record ServiceOrderSummary(
        String orderId,
        String bookingId,
        String guestName,
        String phone,
        String status,
        BigDecimal totalAmount,
        LocalDateTime orderedAt,
        List<ServiceOrderLineSummary> services
) {
}
