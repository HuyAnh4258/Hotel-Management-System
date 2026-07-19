<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/repository/RoomBookingRepository.java
package com.hotel.hms.repository;
=======
package com.hotel.hms.modules.booking_management.repository;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/repository/RoomBookingRepository.java

import com.hotel.hms.entity.RoomBooking;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RoomBookingRepository extends JpaRepository<RoomBooking, String> {
    @Query("select rb from RoomBooking rb where rb.booking.bookingId = :bookingId")
    List<RoomBooking> findByBookingId(@Param("bookingId") String bookingId);

    @Query("""
            select rb from RoomBooking rb
            where rb.room.roomId = :roomId
              and rb.booking.status <> 'CANCELLED'
              and rb.booking.expectedCheckin < :checkout
              and rb.booking.expectedCheckout > :checkin
            """)
    List<RoomBooking> findOverlappingBookings(
            @Param("roomId") String roomId,
            @Param("checkin") LocalDateTime checkin,
            @Param("checkout") LocalDateTime checkout
    );
}
