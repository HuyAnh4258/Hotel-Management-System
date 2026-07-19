package com.hotel.hms.modules.authentication.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ForgotPasswordResetRequest {
    @NotBlank(message = "Email khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @Email(message = "Email khÃ´ng Ä‘Ãºng Ä‘á»‹nh dáº¡ng")
    private String email;

    @NotBlank(message = "OTP khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    @Size(min = 6, max = 6, message = "OTP pháº£i Ä‘Ãºng 6 kÃ½ tá»±")
    private String otp;

    @NotBlank(message = "Mật khẩu mới không được để trống")
    @jakarta.validation.constraints.Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=*!]).{8,}$",
        message = "Mật khẩu phải từ 8 ký tự trở lên, bao gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt (@#$%^&+=*!)"
    )
    private String newPassword;
}
