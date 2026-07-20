package com.hotel.hms.modules.booking_management.dto;

import java.time.LocalDateTime;
import java.util.List;

public record FeedbackSummary(
        String feedbackId,
        String bookingId,
        String guestName,
        String phone,
        String bookingStatus,
        List<String> rooms,
        int rating,
        String comment,
        LocalDateTime createdAt
) {
}
