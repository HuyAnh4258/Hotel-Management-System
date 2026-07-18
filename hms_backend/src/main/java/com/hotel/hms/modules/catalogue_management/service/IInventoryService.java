package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.modules.catalogue_management.dto.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface IInventoryService {

    InventoryCatalogueResponseDTO createInventoryItem(InventoryCatalogueRequestDTO request, String employeeId);

    List<InventoryCatalogueResponseDTO> getAllItems();

    InventoryCatalogueResponseDTO getItemById(String id);

    InventoryCatalogueResponseDTO updateItemDetails(String id, InventoryCatalogueRequestDTO request);

    void deactivateItem(String id);

    InventoryCatalogueResponseDTO updateItemPrice(String id, BigDecimal unitPrice);

    InventoryCatalogueResponseDTO processInventoryAdjustment(InventoryAdjustmentRequestDTO request, String employeeId);

    List<InventoryCatalogueResponseDTO> getLowStockItems();

    List<?> getItemAdjustmentHistory(String itemId);

    List<?> getExpenseReport(LocalDateTime fromDate, LocalDateTime toDate);
}
