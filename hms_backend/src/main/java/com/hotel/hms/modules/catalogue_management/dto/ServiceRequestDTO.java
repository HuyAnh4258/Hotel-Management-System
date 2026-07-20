package com.hotel.hms.modules.catalogue_management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceRequestDTO {

    @NotBlank(message = "TÃªn dá»‹ch vá»¥ khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @Size(max = 100)
    private String serviceName;

    @Size(max = 500)
    private String description;

    @NotNull(message = "GiÃ¡ bÃ¡n khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @DecimalMin(value = "0.0", inclusive = false, message = "GiÃ¡ pháº£i lá»›n hÆ¡n 0")
    @Digits(integer = 16, fraction = 2)
    private BigDecimal unitPrice;

    private Boolean isComposite;

    private java.util.List<RecipeItemDTO> recipeItems;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeItemDTO {
        private String itemId;
        private Integer quantityRequired;
    }
}
