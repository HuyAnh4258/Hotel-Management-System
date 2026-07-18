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
}
