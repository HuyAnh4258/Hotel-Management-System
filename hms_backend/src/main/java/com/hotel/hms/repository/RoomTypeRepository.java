package com.hotel.hms.repository;

import com.hotel.hms.entity.RoomType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoomTypeRepository extends JpaRepository<RoomType, String> {
}