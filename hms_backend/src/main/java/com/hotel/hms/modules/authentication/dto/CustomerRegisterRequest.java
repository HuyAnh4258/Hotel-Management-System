package com.hotel.hms.modules.authentication.dto;

import lombok.Data;

@Data
public class CustomerRegisterRequest {
    private String email;
    @jakarta.validation.constraints.NotBlank(message = "Password is required")
    @jakarta.validation.constraints.Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=*!]).{8,}$",
        message = "Password must be at least 8 characters long, containing uppercase, lowercase, digit, and a special character"
    )
    private String password;
    private String fullName;
    private String phone;
}
