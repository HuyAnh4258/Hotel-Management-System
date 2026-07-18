package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.common.util.IdGenerator;
import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.entity.*;
import com.hotel.hms.modules.catalogue_management.repository.*;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import com.hotel.hms.modules.employee_management.repository.EmployeeProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements IInventoryService {

    private final IInventoryRepository inventoryRepo;
    private final IInventoryAdjustmentRepository adjustmentRepo;
    private final IExpenseRepository expenseRepo;
    private final EmployeeProfileRepository employeeRepo;
    private final IdGenerator idGenerator;

    // ── ITEM CRUD ──

    @Override
    @Transactional
    public InventoryCatalogueResponseDTO createInventoryItem(InventoryCatalogueRequestDTO request, String employeeId) {
        if (inventoryRepo.existsByItemName(request.getItemName())) {
            throw new RuntimeException("Tên vật tư đã tồn tại: " + request.getItemName());
        }

        InventoryItem item = InventoryItem.builder()
                .itemId(idGenerator.generateStaticId("INV", inventoryRepo))
                .itemName(request.getItemName())
                .unitCost(request.getUnitCost())
                .lowStockThreshold(request.getThreshold() != null ? request.getThreshold() : 5)
                .build();

        return toResponse(inventoryRepo.save(item));
    }

    @Override
    public List<InventoryCatalogueResponseDTO> getAllItems() {
        return inventoryRepo.findByIsActiveTrue().stream().map(this::toResponse).toList();
    }

    @Override
    public InventoryCatalogueResponseDTO getItemById(String id) {
        return toResponse(findItemOrThrow(id));
    }

    @Override
    @Transactional
    public InventoryCatalogueResponseDTO updateItemDetails(String id, InventoryCatalogueRequestDTO request) {
        InventoryItem item = findItemOrThrow(id);

        inventoryRepo.findByItemName(request.getItemName()).ifPresent(existing -> {
            if (!existing.getItemId().equals(id)) {
                throw new RuntimeException("Tên vật tư đã tồn tại: " + request.getItemName());
            }
        });

        item.setItemName(request.getItemName());
        item.setUnitCost(request.getUnitCost());
        item.setLowStockThreshold(request.getThreshold() != null ? request.getThreshold() : 5);
        return toResponse(inventoryRepo.save(item));
    }

    @Override
    @Transactional
    public void deactivateItem(String id) {
        InventoryItem item = findItemOrThrow(id);
        item.setIsActive(false);
        inventoryRepo.save(item);
    }

    @Override
    @Transactional
    public InventoryCatalogueResponseDTO updateItemPrice(String id, BigDecimal unitPrice) {
        InventoryItem item = findItemOrThrow(id);
        item.setUnitPrice(unitPrice);
        return toResponse(inventoryRepo.save(item));
    }

    // ── ADJUSTMENT ──

    @Override
    @Transactional
    public InventoryCatalogueResponseDTO processInventoryAdjustment(
            InventoryAdjustmentRequestDTO request, String employeeId) {

        InventoryItem item = findItemOrThrow(request.getItemId());
        EmployeeProfile employee = findEmployeeOrThrow(employeeId);
        AdjustmentType type = request.getType();
        int qty = Math.abs(request.getQuantity());

        switch (type) {
            case RESTOCK -> {
                item.setStockQuantity(item.getStockQuantity() + qty);
                String adjId = createAdjustment(item, employee, qty, type, request.getReason());
                generateExpenseRecord(adjId, item.getUnitCost().multiply(BigDecimal.valueOf(qty)));
            }
            case CONSUME, DAMAGE, LOSS, AUTO_SELL -> {
                item.setStockQuantity(item.getStockQuantity() - qty);
                createAdjustment(item, employee, -qty, type, request.getReason());
            }
            case RECONCILE -> {
                item.setStockQuantity(request.getQuantity());
                createAdjustment(item, employee, request.getQuantity(), type, request.getReason());
            }
        }

        return toResponse(inventoryRepo.save(item));
    }

    @Override
    public List<InventoryCatalogueResponseDTO> getLowStockItems() {
        return inventoryRepo.findLowStockItems().stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public List<InventoryAdjustment> getItemAdjustmentHistory(String itemId) {
        return adjustmentRepo.findByItem_ItemIdOrderByCreatedAtDesc(itemId);
    }

    @Override
    public List<Expense> getExpenseReport(LocalDateTime fromDate, LocalDateTime toDate) {
        return expenseRepo.findByCreatedAtBetween(fromDate, toDate);
    }

    // ── PRIVATE ──

    private String createAdjustment(InventoryItem item, EmployeeProfile employee,
                                     int quantity, AdjustmentType type, String reason) {
        InventoryAdjustment adj = InventoryAdjustment.builder()
                .adjustmentId(idGenerator.generateTransactionalId("ADJ"))
                .item(item)
                .employee(employee)
                .quantity(quantity)
                .type(type)
                .description(reason)
                .build();
        return adjustmentRepo.save(adj).getAdjustmentId();
    }

    private void generateExpenseRecord(String adjustmentId, BigDecimal amount) {
        expenseRepo.save(Expense.builder()
                .expenseId(idGenerator.generateTransactionalId("EXP"))
                .expenseType(ExpenseType.RESTOCK)
                .amount(amount)
                .description("Auto-generated from adjustment: " + adjustmentId)
                .build());
    }

    private InventoryCatalogueResponseDTO toResponse(InventoryItem item) {
        return InventoryCatalogueResponseDTO.builder()
                .itemId(item.getItemId())
                .itemName(item.getItemName())
                .stockQuantity(item.getStockQuantity())
                .unitCost(item.getUnitCost())
                .lowStockThreshold(item.getLowStockThreshold())
                .isActive(item.getIsActive())
                .unitPrice(item.getUnitPrice())
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }

    private InventoryItem findItemOrThrow(String id) {
        return inventoryRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vật tư: " + id));
    }

    private EmployeeProfile findEmployeeOrThrow(String id) {
        return employeeRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy nhân viên: " + id));
    }
}
