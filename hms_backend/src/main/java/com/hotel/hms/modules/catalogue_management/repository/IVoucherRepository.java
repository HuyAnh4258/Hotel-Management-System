package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.booking_management.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface IVoucherRepository extends JpaRepository<Voucher, String> {

    List<Voucher> findByIsActiveTrue();

    Optional<Voucher> findByVoucherCode(String voucherCode);

    boolean existsByVoucherCode(String voucherCode);
}
