<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/repository/BookingRepository.java
package com.hotel.hms.repository;
=======
package com.hotel.hms.modules.booking_management.repository;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/repository/BookingRepository.java

import com.hotel.hms.entity.Booking;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRepository extends JpaRepository<Booking, String> {
    List<Booking> findTop8ByOrderByCreatedAtDesc();
}