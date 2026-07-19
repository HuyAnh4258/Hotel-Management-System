package com.hotel.hms.modules.catalogue_management.entity;

import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "InventoryAdjustment")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryAdjustment {

    @Id
    @Column(name = "AdjustmentId", length = 22, nullable = false)
    private String adjustmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ItemId", nullable = false, foreignKey = @ForeignKey(name = "fk_adj_item"))
    private InventoryItem item;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "EmployeeId", nullable = false, foreignKey = @ForeignKey(name = "fk_adj_employee"))
    private EmployeeProfile employee;

    @Column(name = "Quantity", nullable = false)
    private Integer quantity;

    @Enumerated(EnumType.STRING)
    @Column(name = "Type", length = 22, nullable = false)
    private AdjustmentType type;

    @Column(name = "Description", length = 255)
    private String description;

    @Column(name = "CreatedAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
