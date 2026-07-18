package com.hotel.hms.modules.catalogue_management.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "Expense")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Expense {

    @Id
    @Column(name = "ExpenseId", length = 22, nullable = false)
    private String expenseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AdjustmentId", nullable = true, foreignKey = @ForeignKey(name = "fk_expense_adj"))
    private InventoryAdjustment adjustment;

    @Enumerated(EnumType.STRING)
    @Column(name = "ExpenseType", length = 22, nullable = false)
    @Builder.Default
    private ExpenseType expenseType = ExpenseType.RESTOCK;

    @Column(name = "Amount", precision = 18, scale = 2, nullable = false)
    private BigDecimal amount;

    @Column(name = "Description", length = 255, nullable = false)
    private String description;

    @Column(name = "CreatedAt", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.expenseType == null) this.expenseType = ExpenseType.RESTOCK;
    }
}
