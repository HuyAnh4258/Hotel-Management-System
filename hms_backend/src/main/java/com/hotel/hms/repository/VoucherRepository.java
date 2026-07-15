package com.hotel.hms.repository;

import com.hotel.hms.entity.Voucher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoucherRepository extends JpaRepository<Voucher, String> {
    Optional<Voucher> findByVoucherCodeIgnoreCase(String voucherCode);
}