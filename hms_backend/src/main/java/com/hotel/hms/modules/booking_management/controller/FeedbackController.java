package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.CreateFeedbackRequest;
import com.hotel.hms.modules.booking_management.dto.FeedbackSummary;
import com.hotel.hms.modules.booking_management.service.FeedbackService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/booking/feedbacks")
public class FeedbackController {
    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    @GetMapping
    public ResponseEntity<List<FeedbackSummary>> getFeedbacks() {
        return ResponseEntity.ok(feedbackService.getFeedbacks());
    }

    @GetMapping("/{bookingId}")
    public ResponseEntity<FeedbackSummary> getFeedbackByBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(feedbackService.getFeedbackByBooking(bookingId));
    }

    @PostMapping
    public ResponseEntity<FeedbackSummary> submitFeedback(@Valid @RequestBody CreateFeedbackRequest request) {
        return ResponseEntity.ok(feedbackService.submitFeedback(request));
    }
}
