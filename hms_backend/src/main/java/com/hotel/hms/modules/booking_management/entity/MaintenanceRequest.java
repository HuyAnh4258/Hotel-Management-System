package com.hotel.hms.modules.booking_management.entity;

import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "MaintenanceRequest")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MaintenanceRequest {

    @Id
    @Column(name = "RequestId", length = 20)
    private String requestId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ReporterId", nullable = false)
    private EmployeeProfile reporter;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "RoomId", nullable = false)
    private Room room;

    @Column(name = "Description", length = 500, nullable = false)
    private String description;

    @Column(name = "Status", length = 20, nullable = false)
    private String status = "PENDING";

    @Column(name = "CreatedAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
