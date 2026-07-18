package com.hotel.hms.modules.authentication.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "GuestProfile")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuestProfile {

    @Id
    @Column(name = "GuestId", length = 12, nullable = false)
    private String guestId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "UserId", nullable = false, foreignKey = @ForeignKey(name = "fk_guest_user"))
    private User user;

    @Column(name = "FullName", length = 100, nullable = false)
    private String fullName;

    @Column(name = "Phone", length = 10, nullable = false, unique = true)
    private String phone;

    @Column(name = "IdentityNumber", length = 20, unique = true)
    private String identityNumber;

    @Column(name = "IdentityType", length = 20)
    private String identityType;

    @Column(name = "DateOfBirth")
    private LocalDate dateOfBirth;

    @Column(name = "Gender", length = 10)
    private String gender;

    @Column(name = "Nationality", length = 50)
    private String nationality;

    @Column(name = "Address", length = 255)
    private String address;
}
