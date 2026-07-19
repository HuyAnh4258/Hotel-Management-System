package com.hotel.hms.repository;

import com.hotel.hms.entity.HotelService;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HotelServiceRepository extends JpaRepository<HotelService, String> {
    List<HotelService> findByIsActiveTrueOrderByServiceNameAsc();
}
