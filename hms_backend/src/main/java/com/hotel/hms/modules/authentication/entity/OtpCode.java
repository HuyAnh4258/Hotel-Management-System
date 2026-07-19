package com.hotel.hms.modules.authentication.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "OtpCodes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OtpCode {

    @Id
    @Column(name = "Email", length = 100, nullable = false)
    private String email;

    @Column(name = "Otp", length = 6, nullable = false)
    private String otp;

    @Column(name = "ExpireTime", nullable = false)
    private LocalDateTime expireTime;
}
