package com.hotel.hms.modules.catalogue_management.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "InventoryItem")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryItem {

    @Id
    @Column(name = "ItemId", length = 12, nullable = false)
    private String itemId;

    @Column(name = "ItemName", length = 100, nullable = false, unique = true)
    private String itemName;

    @Column(name = "StockQuantity", nullable = false)
    @Builder.Default
    private Integer stockQuantity = 0;

    @Column(name = "UnitCost", precision = 18, scale = 2, nullable = false)
    private BigDecimal unitCost;

    @Column(name = "UnitPrice", precision = 18, scale = 2, nullable = true)
    private BigDecimal unitPrice;

    @Column(name = "LowStockThreshold", nullable = false)
    @Builder.Default
    private Integer lowStockThreshold = 5;

    @Column(name = "IsActive", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "CreatedAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.stockQuantity == null) this.stockQuantity = 0;
        if (this.lowStockThreshold == null) this.lowStockThreshold = 5;
        if (this.isActive == null) this.isActive = true;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
