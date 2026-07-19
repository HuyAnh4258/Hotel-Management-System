package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.modules.catalogue_management.dto.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface IInventoryService {

    InventoryCatalogueResponseDTO createInventoryItem(InventoryCatalogueRequestDTO request, String employeeId);

    List<InventoryCatalogueResponseDTO> getAllItems();

    InventoryCatalogueResponseDTO getItemById(String id);

    InventoryCatalogueResponseDTO updateItemDetails(String id, InventoryCatalogueRequestDTO request, String employeeId);

    void deactivateItem(String id, String employeeId);

    InventoryCatalogueResponseDTO updateItemPrice(String id, BigDecimal unitPrice, String employeeId);

    InventoryCatalogueResponseDTO processInventoryAdjustment(InventoryAdjustmentRequestDTO request, String employeeId);

    List<InventoryCatalogueResponseDTO> getLowStockItems();

    List<?> getItemAdjustmentHistory(String itemId);

    List<?> getExpenseReport(LocalDateTime fromDate, LocalDateTime toDate);

    List<InventoryCatalogueResponseDTO> getDeactivatedItems();

    void reactivateItem(String id, String employeeId);

    List<InventoryAdjustmentResponseDTO> getAllAdjustments();
}
