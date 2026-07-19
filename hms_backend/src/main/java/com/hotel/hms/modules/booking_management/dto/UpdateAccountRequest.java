package com.hotel.hms.dto;

import java.math.BigDecimal;

public record UpdateAccountRequest(
        String email,
        String fullName,
        String phone,
        String roleName,
        BigDecimal salary,
        String password
) {
}
