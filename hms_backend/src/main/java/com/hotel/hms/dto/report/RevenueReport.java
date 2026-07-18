package com.hotel.hms.dto.report;

import java.math.BigDecimal;
import java.util.List;

public record RevenueReport(
        BigDecimal totalRevenue,
        List<MonthlyData> monthlyRevenue
) {
    public record MonthlyData(String month, BigDecimal amount) {}
}
