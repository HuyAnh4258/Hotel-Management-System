package com.hotel.hms.modules.authentication.repository;

import com.hotel.hms.modules.authentication.entity.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, String> {
    Optional<OtpCode> findByEmail(String email);
    Optional<OtpCode> findByEmailAndOtp(String email, String otp);
}
