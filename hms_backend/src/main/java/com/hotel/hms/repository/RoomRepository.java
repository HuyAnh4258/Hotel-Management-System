package com.hotel.hms.repository;

import com.hotel.hms.entity.Room;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomRepository extends JpaRepository<Room, String> {
    List<Room> findByIsActiveTrue();

    List<Room> findByIsActiveTrueAndStatusIn(List<String> statuses);
}