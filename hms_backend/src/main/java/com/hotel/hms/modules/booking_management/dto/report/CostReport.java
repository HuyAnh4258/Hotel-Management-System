package com.hotel.hms.modules.booking_management.dto.report;

import java.math.BigDecimal;
import java.util.List;

public record CostReport(
        BigDecimal totalCost,
        List<MonthlyData> monthlyCost
) {
    public record MonthlyData(String month, BigDecimal amount) {}
}
