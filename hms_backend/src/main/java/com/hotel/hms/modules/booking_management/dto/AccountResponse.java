package com.hotel.hms.dto;

import java.math.BigDecimal;

public record AccountResponse(
        String userId,
        String username,
        String email,
        boolean isActive,
        String createdAt,
        String employeeId,
        String fullName,
        String phone,
        BigDecimal salary,
        String hireDate,
        String roleName
) {
}
