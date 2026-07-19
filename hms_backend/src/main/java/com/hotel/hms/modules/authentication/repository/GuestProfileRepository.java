package com.hotel.hms.modules.authentication.repository;

import com.hotel.hms.modules.authentication.entity.GuestProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface GuestProfileRepository extends JpaRepository<GuestProfile, String> {

    Optional<GuestProfile> findByPhone(String phone);

    Optional<GuestProfile> findByUser_UserId(String userId);

    boolean existsByPhone(String phone);
}
