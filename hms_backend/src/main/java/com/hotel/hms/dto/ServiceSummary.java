package com.hotel.hms.dto;

import java.math.BigDecimal;

public record ServiceSummary(
        String serviceId,
        String serviceName,
        String description,
        BigDecimal price
) {
}
