package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.Room;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomRepository extends JpaRepository<Room, String> {
    List<Room> findByIsActiveTrue();

    List<Room> findByIsActiveTrueAndStatusIn(List<String> statuses);
}
