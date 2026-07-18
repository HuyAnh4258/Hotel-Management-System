package com.hotel.hms.modules.catalogue_management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceRequestDTO {

    @NotBlank(message = "Tên dịch vụ không được trống")
    @Size(max = 100)
    private String serviceName;

    @Size(max = 500)
    private String description;

    @NotNull(message = "Giá bán không được trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá phải lớn hơn 0")
    @Digits(integer = 16, fraction = 2)
    private BigDecimal unitPrice;
}
