package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.catalogue_management.entity.ServiceInventoryRecipe;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ServiceInventoryRecipeRepository extends JpaRepository<ServiceInventoryRecipe, ServiceInventoryRecipe.ServiceInventoryRecipeId> {

    List<ServiceInventoryRecipe> findByService_ServiceId(String serviceId);

    void deleteByService_ServiceIdAndInventoryItem_ItemId(String serviceId, String itemId);
}
