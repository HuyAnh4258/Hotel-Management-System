package com.hotel.hms.modules.authentication.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "Roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {

    @Id
    @Column(name = "RoleId", length = 12, nullable = false)
    private String roleId;

    @Column(name = "RoleName", length = 50, nullable = false, unique = true)
    private String roleName;

    @Column(name = "Description", length = 255)
    private String description;
}
