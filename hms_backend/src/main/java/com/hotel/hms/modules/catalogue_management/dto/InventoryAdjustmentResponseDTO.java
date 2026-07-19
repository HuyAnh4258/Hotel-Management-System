package com.hotel.hms.modules.catalogue_management.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryAdjustmentResponseDTO {

    private String adjustmentId;
    private String itemId;
    private String itemName;
    private String employeeId;
    private String employeeName;
    private Integer quantity;
    private String type;
    private String description;
    private LocalDateTime createdAt;
}
