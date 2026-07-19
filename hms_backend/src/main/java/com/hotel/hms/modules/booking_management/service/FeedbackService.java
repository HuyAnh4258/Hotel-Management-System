package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.CreateFeedbackRequest;
import com.hotel.hms.modules.booking_management.dto.FeedbackSummary;
import com.hotel.hms.modules.booking_management.entity.Booking;
import com.hotel.hms.modules.booking_management.entity.Feedback;
import com.hotel.hms.modules.booking_management.entity.Room;
import com.hotel.hms.modules.booking_management.repository.BookingRepository;
import com.hotel.hms.modules.booking_management.repository.FeedbackRepository;
import com.hotel.hms.modules.booking_management.repository.RoomBookingRepository;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class FeedbackService {
    private final BookingRepository bookingRepository;
    private final FeedbackRepository feedbackRepository;
    private final RoomBookingRepository roomBookingRepository;

    public FeedbackService(
            BookingRepository bookingRepository,
            FeedbackRepository feedbackRepository,
            RoomBookingRepository roomBookingRepository
    ) {
        this.bookingRepository = bookingRepository;
        this.feedbackRepository = feedbackRepository;
        this.roomBookingRepository = roomBookingRepository;
    }

    @Transactional(readOnly = true)
    public List<FeedbackSummary> getFeedbacks() {
        return feedbackRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toFeedbackSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public FeedbackSummary getFeedbackByBooking(String bookingId) {
        return feedbackRepository.findByBookingBookingId(bookingId)
                .map(this::toFeedbackSummary)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Feedback not found"));
    }

    @Transactional
    public FeedbackSummary submitFeedback(CreateFeedbackRequest request) {
        String bookingId = request.bookingId() == null ? "" : request.bookingId().trim();
        if (bookingId.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "bookingId is required");
        }

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        String comment = request.comment() == null ? "" : request.comment().trim();
        Byte rating = (byte) request.rating();
        Feedback feedback = feedbackRepository.findByBookingBookingId(bookingId)
                .orElseGet(() -> new Feedback(generateId("FDB", 20), booking, rating, comment, LocalDateTime.now()));

        feedback.setRating(rating);
        feedback.setComment(comment);
        feedback.setCreatedAt(LocalDateTime.now());

        return toFeedbackSummary(feedbackRepository.save(feedback));
    }

    private FeedbackSummary toFeedbackSummary(Feedback feedback) {
        Booking booking = feedback.getBooking();
        List<String> rooms = booking == null || booking.getBookingId() == null
                ? List.of()
                : roomBookingRepository.findByBookingId(booking.getBookingId()).stream()
                .map(roomBooking -> {
                    Room room = roomBooking.getRoom();
                    if (room == null) {
                        return "";
                    }
                    return room.getRoomName() + (room.getRoomId() != null ? " (" + room.getRoomId() + ")" : "");
                })
                .filter(value -> value != null && !value.isBlank())
                .toList();

        return new FeedbackSummary(
                feedback.getFeedbackId(),
                booking != null ? booking.getBookingId() : "",
                booking != null && booking.getGuest() != null ? booking.getGuest().getFullName() : "",
                booking != null && booking.getGuest() != null ? booking.getGuest().getPhone() : "",
                booking != null ? booking.getStatus() : "",
                rooms,
                feedback.getRating() == null ? 0 : feedback.getRating().intValue(),
                feedback.getComment(),
                feedback.getCreatedAt()
        );
    }

    private String generateId(String prefix, int maxLength) {
        StringBuilder value = new StringBuilder(prefix);
        String digits = String.valueOf(System.currentTimeMillis());

        for (int i = digits.length() - 1; i >= 0 && value.length() < maxLength; i--) {
            value.append(digits.charAt(i));
        }

        while (value.length() < maxLength) {
            value.append((char) ('0' + Math.abs((int) System.nanoTime()) % 10));
        }

        return value.substring(0, maxLength);
    }
}
