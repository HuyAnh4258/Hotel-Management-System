package com.hotel.hms.modules.authentication.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequest {

    @NotBlank(message = "Tên đăng nhập hoặc email không được trống")
    private String username;  // Can be username or email

    @NotBlank(message = "Mật khẩu không được trống")
    private String password;
}
