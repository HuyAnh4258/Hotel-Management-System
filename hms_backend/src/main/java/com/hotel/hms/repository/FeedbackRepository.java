package com.hotel.hms.repository;

import com.hotel.hms.entity.Feedback;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeedbackRepository extends JpaRepository<Feedback, String> {
    Optional<Feedback> findByBookingBookingId(String bookingId);

    List<Feedback> findAllByOrderByCreatedAtDesc();
}
