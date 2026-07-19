package com.hotel.hms.modules.catalogue_management.dto;

import com.hotel.hms.modules.catalogue_management.entity.AdjustmentType;
import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryAdjustmentRequestDTO {

    @NotBlank(message = "MÃ£ váº­t tÆ° khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    private String itemId;

    @NotNull(message = "Sá»‘ lÆ°á»£ng khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    private Integer quantity;

    @NotNull(message = "Loáº¡i Ä‘iá»u chá»‰nh khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    private AdjustmentType type;

    @DecimalMin(value = "0.0", inclusive = true)
    @Digits(integer = 18, fraction = 2)
    private BigDecimal unitCost;

    @Size(max = 255, message = "LÃ½ do tá»‘i Ä‘a 255 kÃ½ tá»±")
    private String reason;
}
