package com.hotel.hms.modules.employee_management.repository;

import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmployeeProfileRepository extends JpaRepository<EmployeeProfile, String> {
}