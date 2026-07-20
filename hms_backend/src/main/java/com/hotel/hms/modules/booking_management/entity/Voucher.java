package com.hotel.hms.modules.booking_management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Voucher")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Voucher {
    @Id
    @Column(name = "VoucherId", length = 12)
    private String voucherId;

    @Column(name = "VoucherCode", nullable = false, length = 50)
    private String voucherCode;

    @Column(name = "DiscountPercent", precision = 5, scale = 2)
    private BigDecimal discountPercent;

    @Column(name = "MaxDiscountAmount", precision = 18, scale = 2)
    private BigDecimal maxDiscountAmount;

    @Column(name = "DiscountAmount", precision = 18, scale = 2)
    private BigDecimal discountAmount;

    @Column(name = "MinBookingValue", precision = 18, scale = 2)
    private BigDecimal minBookingValue;

    @Column(name = "ExpiryTime", nullable = false)
    private LocalDateTime expiryTime;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    public String getVoucherId() {
        return voucherId;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public BigDecimal getDiscountPercent() {
        return discountPercent;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public BigDecimal getMinBookingValue() {
        return minBookingValue;
    }

    public LocalDateTime getExpiryTime() {
        return expiryTime;
    }

    public Boolean getIsActive() {
        return isActive;
    }
}
