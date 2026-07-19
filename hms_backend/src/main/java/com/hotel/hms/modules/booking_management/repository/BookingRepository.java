package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.Booking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, String> {
    List<Booking> findTop8ByOrderByCreatedAtDesc();

    List<Booking> findByGuest_User_UserIdOrderByCreatedAtDesc(String userId);
}
