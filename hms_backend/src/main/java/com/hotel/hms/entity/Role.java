package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "Roles")
@Getter
@Setter
@NoArgsConstructor
public class Role {
    @Id
    @Column(name = "RoleId", length = 12)
    private String roleId;

    @Column(name = "RoleName", nullable = false, unique = true, length = 50)
    private String roleName;

    @Column(name = "Description", length = 255)
    private String description;
}
