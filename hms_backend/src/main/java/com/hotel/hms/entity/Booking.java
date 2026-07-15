package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Booking")
public class Booking {
    @Id
    @Column(name = "BookingId", length = 20)
    private String bookingId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "GuestId")
    private GuestProfile guest;

    @ManyToOne
    @JoinColumn(name = "VoucherId")
    private Voucher voucher;

    @Column(name = "ExpectedCheckin", nullable = false)
    private LocalDateTime expectedCheckin;

    @Column(name = "ExpectedCheckout", nullable = false)
    private LocalDateTime expectedCheckout;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "TotalAmount", nullable = false, precision = 18, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    public String getBookingId() {
        return bookingId;
    }

    public GuestProfile getGuest() {
        return guest;
    }

    public Voucher getVoucher() {
        return voucher;
    }

    public LocalDateTime getExpectedCheckin() {
        return expectedCheckin;
    }

    public LocalDateTime getExpectedCheckout() {
        return expectedCheckout;
    }

    public String getStatus() {
        return status;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}