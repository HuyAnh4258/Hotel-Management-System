package com.hotel.hms.modules.catalogue_management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryCatalogueRequestDTO {

    @NotBlank(message = "Tên vật tư không được trống")
    @Size(max = 100, message = "Tên vật tư tối đa 100 ký tự")
    private String itemName;

    @NotNull(message = "Giá nhập không được trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá nhập phải lớn hơn 0")
    @Digits(integer = 18, fraction = 2, message = "Định dạng giá không hợp lệ (tối đa 18 số)")
    private BigDecimal unitCost;

    @Min(value = 0, message = "Ngưỡng tồn kho tối thiểu là 0")
    private Integer threshold;
}
