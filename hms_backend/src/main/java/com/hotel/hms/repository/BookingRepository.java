package com.hotel.hms.repository;

import com.hotel.hms.entity.Booking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, String> {
    List<Booking> findTop8ByOrderByCreatedAtDesc();

    List<Booking> findByGuest_UserIdOrderByCreatedAtDesc(String userId);
}
