package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.RoomType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomTypeRepository extends JpaRepository<RoomType, String> {
}