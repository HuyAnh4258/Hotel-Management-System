package com.hotel.hms.modules.catalogue_management.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Service")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Service {

    @Id
    @Column(name = "ServiceId", length = 12, nullable = false)
    private String serviceId;

    @Column(name = "ServiceName", length = 100, nullable = false, unique = true)
    private String serviceName;

    @Column(name = "Description", length = 500)
    private String description;

    @Column(name = "UnitPrice", precision = 18, scale = 2, nullable = false)
    private BigDecimal unitPrice;

    @Column(name = "IsActive", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "CreatedAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.isActive == null) this.isActive = true;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
