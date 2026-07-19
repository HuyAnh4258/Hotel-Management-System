package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.catalogue_management.entity.InventoryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface IInventoryRepository extends JpaRepository<InventoryItem, String> {

    List<InventoryItem> findByIsActiveTrue();

    List<InventoryItem> findByItemNameContainingIgnoreCase(String name);

    @Query("SELECT i FROM InventoryItem i WHERE i.stockQuantity <= i.lowStockThreshold AND i.isActive = true")
    List<InventoryItem> findLowStockItems();

    Optional<InventoryItem> findByItemName(String itemName);

    boolean existsByItemName(String itemName);

    List<InventoryItem> findByIsActiveFalse();
}
