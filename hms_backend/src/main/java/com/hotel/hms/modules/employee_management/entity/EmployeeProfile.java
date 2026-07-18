package com.hotel.hms.modules.employee_management.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "EmployeeProfile")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmployeeProfile {

    @Id
    @Column(name = "UserId", length = 12, nullable = false)
    private String userId;

    @Column(name = "EmployeeId", length = 12, nullable = false, unique = true)
    private String employeeId;

    @Column(name = "FullName", length = 100, nullable = false)
    private String fullName;

    @Column(name = "Phone", length = 10, nullable = false, unique = true)
    private String phone;

    @Column(name = "Salary", precision = 18, scale = 2)
    private BigDecimal salary;

    @Column(name = "HireDate", nullable = false)
    private LocalDate hireDate;
}
