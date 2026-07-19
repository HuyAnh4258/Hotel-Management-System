package com.hotel.hms.modules.authentication.controller;

import com.hotel.hms.modules.authentication.dto.*;
import com.hotel.hms.modules.authentication.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/forgot-password/request")
    public ResponseEntity<String> requestForgotPasswordOtp(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.requestForgotPasswordOtp(request);
        return ResponseEntity.ok("MÃ£ OTP Ä‘Ã£ Ä‘Æ°á»£c gá»­i Ä‘áº¿n email cá»§a báº¡n.");
    }

    @PostMapping("/forgot-password/verify")
    public ResponseEntity<String> verifyForgotPasswordOtp(@Valid @RequestBody ForgotPasswordVerifyRequest request) {
        authService.verifyForgotPasswordOtp(request);
        return ResponseEntity.ok("MÃ£ OTP há»£p lá»‡.");
    }

    @PostMapping("/forgot-password/reset")
    public ResponseEntity<String> resetPassword(@Valid @RequestBody ForgotPasswordResetRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok("Máº­t kháº©u cá»§a báº¡n Ä‘Ã£ Ä‘Æ°á»£c Ä‘áº·t láº¡i thÃ nh cÃ´ng.");
    }
}
