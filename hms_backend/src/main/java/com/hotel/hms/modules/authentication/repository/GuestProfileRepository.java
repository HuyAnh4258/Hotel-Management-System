package com.hotel.hms.modules.authentication.repository;

import com.hotel.hms.entity.GuestProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository("authGuestProfileRepository")
public interface GuestProfileRepository extends JpaRepository<GuestProfile, String> {

    Optional<GuestProfile> findByUserId(String userId);

    boolean existsByPhone(String phone);
}
