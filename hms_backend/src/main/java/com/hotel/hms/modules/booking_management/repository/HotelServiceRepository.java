package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.HotelService;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HotelServiceRepository extends JpaRepository<HotelService, String> {
    List<HotelService> findByIsActiveTrueOrderByServiceNameAsc();
}
