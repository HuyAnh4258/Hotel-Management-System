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
    @Pattern(regexp = "^0\\d{9}$", message = "Số điện thoại phải 10 số, bắt đầu bằng 0")
    private String phone;
}
