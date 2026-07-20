package com.hotel.hms.modules.booking_management.dto;

import java.math.BigDecimal;

public record ServiceSummary(
        String serviceId,
        String serviceName,
        String description,
        BigDecimal price
) {
}
