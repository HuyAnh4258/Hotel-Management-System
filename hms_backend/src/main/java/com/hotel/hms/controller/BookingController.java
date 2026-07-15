package com.hotel.hms.controller;

import com.hotel.hms.dto.BookingSummary;
import com.hotel.hms.dto.CreateBookingRequest;
import com.hotel.hms.dto.HomepageResponse;
import com.hotel.hms.service.BookingService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/booking")
public class BookingController {
    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @GetMapping("/homepage")
    public ResponseEntity<HomepageResponse> getHomepage() {
        return ResponseEntity.ok(bookingService.getHomepage());
    }

    @GetMapping
    public ResponseEntity<List<BookingSummary>> getBookingsByDate(@RequestParam(name = "date", required = false) String date) {
        LocalDate targetDate = (date == null || date.isBlank()) ? LocalDate.now() : LocalDate.parse(date);
        return ResponseEntity.ok(bookingService.getBookingsByDate(targetDate));
    }

    @PatchMapping("/{bookingId}/status")
    public ResponseEntity<BookingSummary> updateBookingStatus(
            @PathVariable("bookingId") String bookingId,
            @RequestParam(name = "status") String status
    ) {
        return ResponseEntity.ok(bookingService.updateBookingStatus(bookingId, status));
    }

    @PostMapping
    public ResponseEntity<BookingSummary> createBooking(@Valid @RequestBody CreateBookingRequest request) {
        return ResponseEntity.ok(bookingService.createBooking(request));
    }
}