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

    @NotBlank(message = "Mã vật tư không được trống")
    private String itemId;

    @NotNull(message = "Số lượng không được trống")
    private Integer quantity;

    @NotNull(message = "Loại điều chỉnh không được trống")
    private AdjustmentType type;

    @DecimalMin(value = "0.0", inclusive = true)
    @Digits(integer = 18, fraction = 2)
    private BigDecimal unitCost;

    @Size(max = 255, message = "Lý do tối đa 255 ký tự")
    private String reason;
}
