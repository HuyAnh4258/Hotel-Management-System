package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "`Order`") // Using backticks because ORDER is a SQL keyword
@Getter
@Setter
@NoArgsConstructor
public class ServiceOrder {

    @Id
    @Column(name = "OrderId", length = 20)
    private String orderId;

    @Column(name = "EmployeeId", length = 12, nullable = false)
    private String employeeId;

    @Column(name = "BookingId", length = 20, nullable = false)
    private String bookingId;

    @Column(name = "TotalAmount", precision = 18, scale = 2, nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "Status", length = 20, nullable = false)
    private String status = "PENDING"; // PENDING|IN_PROGRESS|COMPLETED|CANCELLED

    @Column(name = "OrderedAt", nullable = false)
    private LocalDateTime orderedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "BookingId", insertable = false, updatable = false)
    private Booking booking;
}
