package com.hotel.hms.repository;

import com.hotel.hms.entity.GuestProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GuestProfileRepository extends JpaRepository<GuestProfile, String> {
    Optional<GuestProfile> findByPhone(String phone);

    Optional<GuestProfile> findByUserId(String userId);

    boolean existsByPhone(String phone);
}
