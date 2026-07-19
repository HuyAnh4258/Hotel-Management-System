package com.hotel.hms.modules.authentication.dto;

import lombok.Data;

@Data
public class CustomerRegisterRequest {
    private String email;
    private String password;
    private String fullName;
    private String phone;
}