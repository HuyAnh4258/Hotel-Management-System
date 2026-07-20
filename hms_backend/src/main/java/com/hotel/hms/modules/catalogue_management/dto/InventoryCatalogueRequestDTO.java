package com.hotel.hms.modules.catalogue_management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryCatalogueRequestDTO {

    @NotBlank(message = "TÃªn váº­t tÆ° khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @Size(max = 100, message = "TÃªn váº­t tÆ° tá»‘i Ä‘a 100 kÃ½ tá»±")
    private String itemName;

    @Size(max = 500, message = "MÃ´ táº£ tá»‘i Ä‘a 500 kÃ½ tá»±")
    private String description;

    @NotNull(message = "GiÃ¡ nháº­p khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @DecimalMin(value = "0.0", inclusive = false, message = "GiÃ¡ nháº­p pháº£i lá»›n hÆ¡n 0")
    @Digits(integer = 18, fraction = 2, message = "Äá»‹nh dáº¡ng giÃ¡ khÃ´ng há»£p lá»‡ (tá»‘i Ä‘a 18 sá»‘)")
    private BigDecimal unitCost;

    @Min(value = 0, message = "NgÆ°á»¡ng tá»“n kho tá»‘i thiá»ƒu lÃ  0")
    private Integer threshold;
}
