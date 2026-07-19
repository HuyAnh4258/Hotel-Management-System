<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/repository/RoomRepository.java
package com.hotel.hms.repository;
=======
package com.hotel.hms.modules.booking_management.repository;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/repository/RoomRepository.java

import com.hotel.hms.entity.Room;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomRepository extends JpaRepository<Room, String> {
    List<Room> findByIsActiveTrue();

    List<Room> findByIsActiveTrueAndStatusIn(List<String> statuses);
}
