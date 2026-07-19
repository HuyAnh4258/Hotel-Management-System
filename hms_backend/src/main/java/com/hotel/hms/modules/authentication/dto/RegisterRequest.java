package com.hotel.hms.modules.authentication.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterRequest {

    @NotBlank @Size(min = 3, max = 50)
    private String username;

    @NotBlank @Email @Size(max = 100)
    private String email;

    @NotBlank @Size(min = 6, max = 100)
    private String password;

    @NotBlank @Size(max = 100)
    private String fullName;

    @NotBlank @Size(min = 10, max = 10)
    @Pattern(regexp = "^0\\d{9}$", message = "Sá»‘ Ä‘iá»‡n thoáº¡i pháº£i 10 sá»‘, báº¯t Ä‘áº§u báº±ng 0")
    private String phone;
}
