package com.hotel.hms.security;

import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.List;

@Component
public class JwtTokenProvider {

    public String generateToken(String userId, String username, List<String> roles) {
        String payload = String.join("|",
                userId == null ? "" : userId,
                username == null ? "" : username,
                String.join(",", roles == null ? List.of() : roles),
                String.valueOf(Instant.now().getEpochSecond())
        );
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(payload.getBytes(StandardCharsets.UTF_8));
    }
}