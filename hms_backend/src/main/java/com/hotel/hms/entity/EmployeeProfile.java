package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * JPA Entity for the EmployeeProfile table.
 * PK = UserId (shared with User table via @MapsId).
 */
@Entity
@Table(name = "EmployeeProfile")
@Getter
@Setter
@NoArgsConstructor
public class EmployeeProfile {
    @Id
    @Column(name = "UserId", length = 12)
    private String userId;

    @MapsId
    @OneToOne
    @JoinColumn(name = "UserId")
    private UserAccount user;

    @Column(name = "EmployeeId", nullable = false, unique = true, length = 12)
    private String employeeId;

    @Column(name = "FullName", nullable = false, length = 100)
    private String fullName;

    @Column(name = "Phone", nullable = false, unique = true, length = 10)
    private String phone;

    @Column(name = "Salary", precision = 18, scale = 2)
    private BigDecimal salary;

    @Column(name = "HireDate", nullable = false)
    private LocalDate hireDate;
}
