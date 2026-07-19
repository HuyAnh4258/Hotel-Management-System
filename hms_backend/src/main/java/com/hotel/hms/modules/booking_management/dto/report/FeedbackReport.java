package com.hotel.hms.modules.booking_management.dto.report;

import java.util.List;

public record FeedbackReport(
        double averageRating,
        int totalReviews,
        List<FeedbackItem> recentFeedbacks
) {
    public record FeedbackItem(
            String guestName,
            int rating,
            String comment,
            String date
    ) {}
}
