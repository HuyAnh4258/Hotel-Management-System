package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.Voucher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoucherRepository extends JpaRepository<Voucher, String> {
    Optional<Voucher> findByVoucherCodeIgnoreCase(String voucherCode);
}
