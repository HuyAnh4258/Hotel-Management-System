package com.hotel.hms.modules.employee_management.entity;

import com.hotel.hms.modules.authentication.entity.User;
import jakarta.persistence.*;
import lombok.*;

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

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "UserId", nullable = false, foreignKey = @ForeignKey(name = "fk_employee_user"))
    private User user;

    @Column(name = "FullName", length = 100, nullable = false)
    private String fullName;

    @Column(name = "Phone", length = 10)
    private String phone;

    @Column(name = "HireDate")
    private LocalDate hireDate;
}