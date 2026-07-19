package com.hotel.hms.modules.catalogue_management.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryCatalogueResponseDTO {

    private String itemId;
    private String itemName;
    private String description;
    private Integer stockQuantity;
    private BigDecimal unitCost;
    private BigDecimal unitPrice;
    private Integer lowStockThreshold;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
