package com.hotel.hms.modules.authentication.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequest {

    @NotBlank(message = "TÃªn Ä‘Äƒng nháº­p hoáº·c email khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    private String username;  // Can be username or email

    @NotBlank(message = "Máº­t kháº©u khÃ´ng Ä‘Æ°á»£c trá»‘ng")
    private String password;
}
