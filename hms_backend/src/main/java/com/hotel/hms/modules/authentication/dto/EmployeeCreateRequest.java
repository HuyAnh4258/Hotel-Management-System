package com.hotel.hms.modules.authentication.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmployeeCreateRequest {

    @NotBlank @Size(min = 3, max = 50)
    private String username;

    @NotBlank @Email @Size(max = 100)
    private String email;

    @NotBlank @Size(max = 100)
    private String fullName;

    @NotBlank @Size(min = 10, max = 10)
    @Pattern(regexp = "^0\\d{9}$")
    private String phone;

    @NotBlank
    private String role;  // MANAGER, RECEPTIONIST, SERVICE_STAFF, HOUSEKEEPER
}
