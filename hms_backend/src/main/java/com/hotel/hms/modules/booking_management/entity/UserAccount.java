package com.hotel.hms.modules.booking_management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.hotel.hms.modules.authentication.entity.Role;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;

/**
 * JPA Entity for the `User` table.
 * Named "UserAccount" to avoid conflict with SQL reserved word in code references,
 * but maps to the physical "User" table via @Table.
 */
@Entity
@Table(name = "`User`")
@Getter
@Setter
@NoArgsConstructor
public class UserAccount {
    @Id
    @Column(name = "UserId", length = 12)
    private String userId;

    @Column(name = "Username", nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "Email", nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "HashedPassword", nullable = false, length = 255)
    private String hashedPassword;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "UserRole",
            joinColumns = @JoinColumn(name = "UserId"),
            inverseJoinColumns = @JoinColumn(name = "RoleId")
    )
    private Set<Role> roles = new HashSet<>();

    @OneToOne(mappedBy = "user", fetch = FetchType.LAZY)
    private EmployeeProfile employeeProfile;
}
