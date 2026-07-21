package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.MaintenanceRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MaintenanceRequestRepository extends JpaRepository<MaintenanceRequest, String> {
}
