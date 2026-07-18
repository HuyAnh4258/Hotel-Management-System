package com.hotel.hms.repository;

import com.hotel.hms.entity.EmployeeProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmployeeProfileRepository extends JpaRepository<EmployeeProfile, String> {
    boolean existsByPhone(String phone);

    Optional<EmployeeProfile> findByPhone(String phone);
}
