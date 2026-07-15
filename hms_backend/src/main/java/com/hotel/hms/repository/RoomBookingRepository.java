package com.hotel.hms.repository;

import com.hotel.hms.entity.RoomBooking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RoomBookingRepository extends JpaRepository<RoomBooking, String> {
    @Query("select rb from RoomBooking rb where rb.booking.bookingId = :bookingId")
    List<RoomBooking> findByBookingId(@Param("bookingId") String bookingId);
}