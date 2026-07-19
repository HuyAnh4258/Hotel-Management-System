package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "GuestProfile")
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuestProfile {
    @Id
    @Column(name = "GuestId", length = 12)
    private String guestId;

    @Column(name = "UserId", nullable = false, length = 12)
    private String userId;

    @Column(name = "FullName", nullable = false, length = 100)
    private String fullName;

    @Column(name = "Phone", nullable = false, length = 10)
    private String phone;

    public String getGuestId() {
        return guestId;
    }

    public String getUserId() {
        return userId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhone() {
        return phone;
    }
}