package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.catalogue_management.entity.InventoryAdjustment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface IInventoryAdjustmentRepository extends JpaRepository<InventoryAdjustment, String> {

    List<InventoryAdjustment> findByItem_ItemIdOrderByCreatedAtDesc(String itemId);

    List<InventoryAdjustment> findByTypeAndCreatedAtBetween(
            String type, LocalDateTime from, LocalDateTime to);

    List<InventoryAdjustment> findByEmployee_UserId(String employeeId);

    List<InventoryAdjustment> findAllByOrderByCreatedAtDesc();
}
