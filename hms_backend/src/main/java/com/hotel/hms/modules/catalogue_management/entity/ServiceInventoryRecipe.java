package com.hotel.hms.modules.catalogue_management.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Entity
@Table(name = "Service_Inventory_Recipe")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(ServiceInventoryRecipe.ServiceInventoryRecipeId.class)
public class ServiceInventoryRecipe {

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ServiceId", nullable = false, foreignKey = @ForeignKey(name = "fk_recipe_service"))
    private Service service;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "InventoryItemId", nullable = false, foreignKey = @ForeignKey(name = "fk_recipe_item"))
    private InventoryItem inventoryItem;

    @Column(name = "QuantityRequired", nullable = false)
    @Builder.Default
    private Integer quantityRequired = 1;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class ServiceInventoryRecipeId implements Serializable {
        private String service;
        private String inventoryItem;
    }
}
