package com.hotel.hms.dto;

import java.math.BigDecimal;

public record ServiceOrderLineSummary(
        String serviceId,
        String serviceName,
        int quantity,
        BigDecimal priceAtOrder,
        BigDecimal lineTotal
) {
}
