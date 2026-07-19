package com.hotel.hms.modules.catalogue_management.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceResponseDTO {

    private String serviceId;
    private String serviceName;
    private String description;
    private BigDecimal unitPrice;
    private Boolean isActive;
    private LocalDateTime createdAt;

    private Boolean isComposite;
    private java.util.List<RecipeItemResponseDTO> recipeItems;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RecipeItemResponseDTO {
        private String itemId;
        private String itemName;
        private Integer quantityRequired;
        private BigDecimal unitPrice;
    }
}
