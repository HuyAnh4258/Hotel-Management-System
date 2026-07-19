package com.hotel.hms.modules.catalogue_management.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoucherCatalogueResponseDTO {

    private String voucherId;
    private String voucherCode;
    private BigDecimal discountPercent;
    private BigDecimal maxDiscountAmount;
    private BigDecimal discountAmount;
    private BigDecimal minBookingValue;
    private LocalDateTime expiryTime;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
