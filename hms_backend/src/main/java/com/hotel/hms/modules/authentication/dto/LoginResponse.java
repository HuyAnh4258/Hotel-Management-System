package com.hotel.hms.modules.authentication.dto;

import lombok.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponse {

    private String accessToken;
    private String userId;
    private String username;
    private List<String> roles;
    private String fullName;
}
