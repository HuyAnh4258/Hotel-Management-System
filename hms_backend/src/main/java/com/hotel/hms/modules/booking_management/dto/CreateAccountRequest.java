package com.hotel.hms.modules.booking_management.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;

public record CreateAccountRequest(
        @NotBlank(message = "Username is required")
        @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
        String username,

        @NotBlank(message = "Email is required")
        @Email(message = "Email is invalid")
        String email,

        @NotBlank(message = "Password is required")
        @jakarta.validation.constraints.Pattern(
            regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=*!]).{8,}$",
            message = "Password must be at least 8 characters long, containing uppercase, lowercase, digit, and a special character"
        )
        String password,

        @NotBlank(message = "Full name is required")
        @Size(max = 100, message = "Full name must be at most 100 characters")
        String fullName,

        @NotBlank(message = "Phone is required")
        @Size(min = 10, max = 10, message = "Phone must be exactly 10 digits")
        String phone,

        @NotBlank(message = "Role is required")
        String roleName,

        BigDecimal salary,

        LocalDate hireDate
) {
}
