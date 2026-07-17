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
        if (date == null || date.isBlank()) {
            return ResponseEntity.ok(bookingService.getAllBookings());
        }

        LocalDate targetDate = LocalDate.parse(date);
        return ResponseEntity.ok(bookingService.getBookingsByDate(targetDate));
    }

    @GetMapping("/available-rooms")
    public ResponseEntity<?> getAvailableRooms(
            @RequestParam(name = "checkin") String checkin,
            @RequestParam(name = "checkout") String checkout
    ) {
        return ResponseEntity.ok(
                bookingService.getAvailableRoomsByDateRange(
                        LocalDate.parse(checkin),
                        LocalDate.parse(checkout)
                )
        );
    }

    @GetMapping("/rooms")
    public ResponseEntity<?> getRoomsByStatus(
            @RequestParam(name = "status", required = false) String status
    ) {
        return ResponseEntity.ok(bookingService.getRoomsByStatus(status));
    }

    @GetMapping("/{bookingId}/changeable-rooms")
    public ResponseEntity<?> getChangeableRooms(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(bookingService.getChangeableRooms(bookingId));
    }

    @PatchMapping("/{bookingId}/status")
    public ResponseEntity<BookingSummary> updateBookingStatus(
            @PathVariable("bookingId") String bookingId,
            @RequestParam(name = "status") String status
    ) {
        return ResponseEntity.ok(bookingService.updateBookingStatus(bookingId, status));
    }

    @PatchMapping("/{bookingId}")
    public ResponseEntity<BookingSummary> updateBookingDetails(
            @PathVariable("bookingId") String bookingId,
            @Valid @RequestBody CreateBookingRequest request
    ) {
        return ResponseEntity.ok(bookingService.updateBookingDetails(bookingId, request));
    }

    @PatchMapping("/{bookingId}/change-room")
    public ResponseEntity<BookingSummary> changeBookingRoom(
            @PathVariable("bookingId") String bookingId,
            @RequestParam(name = "roomId") String roomId
    ) {
        return ResponseEntity.ok(bookingService.changeBookingRoom(bookingId, roomId));
    }

    @PatchMapping("/{bookingId}/cancel-request")
    public ResponseEntity<BookingSummary> requestCancelBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(bookingService.requestCancelBooking(bookingId));
    }

    @PatchMapping("/{bookingId}/approve-cancel")
    public ResponseEntity<BookingSummary> approveCancelBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(bookingService.approveCancelBooking(bookingId));
    }

    @PatchMapping("/{bookingId}/reject-cancel")
    public ResponseEntity<BookingSummary> rejectCancelBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(bookingService.rejectCancelBooking(bookingId));
    }

    @PostMapping
    public ResponseEntity<BookingSummary> createBooking(@Valid @RequestBody CreateBookingRequest request) {
        return ResponseEntity.ok(bookingService.createBooking(request));
    }
}