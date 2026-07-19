<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/repository/VoucherRepository.java
package com.hotel.hms.repository;
=======
package com.hotel.hms.modules.booking_management.repository;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/repository/VoucherRepository.java

import com.hotel.hms.entity.Voucher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoucherRepository extends JpaRepository<Voucher, String> {
    Optional<Voucher> findByVoucherCodeIgnoreCase(String voucherCode);
}
