package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.common.util.IdGenerator;
import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.entity.*;
import com.hotel.hms.modules.catalogue_management.repository.*;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import com.hotel.hms.modules.employee_management.repository.EmployeeProfileRepository;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

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
    private final SimpMessagingTemplate messagingTemplate;

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
                .description(request.getDescription())
                .unitCost(request.getUnitCost())
                .lowStockThreshold(request.getThreshold() != null ? request.getThreshold() : 5)
                .build();

        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        broadcastInventoryUpdate(response);
        return response;
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
    public InventoryCatalogueResponseDTO updateItemDetails(String id, InventoryCatalogueRequestDTO request, String employeeId) {
        InventoryItem item = findItemOrThrow(id);
        EmployeeProfile employee = findEmployeeOrThrow(employeeId);

        inventoryRepo.findByItemName(request.getItemName()).ifPresent(existing -> {
            if (!existing.getItemId().equals(id)) {
                throw new RuntimeException("Tên vật tư đã tồn tại: " + request.getItemName());
            }
        });

        item.setItemName(request.getItemName());
        item.setDescription(request.getDescription());
        item.setUnitCost(request.getUnitCost());
        item.setLowStockThreshold(request.getThreshold() != null ? request.getThreshold() : 5);
        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        
        createAdjustment(item, employee, 0, AdjustmentType.UPDATE, "Cập nhật chi tiết vật tư (Tên: " + item.getItemName() + ")");
        
        broadcastInventoryUpdate(response);
        return response;
    }

    @Override
    @Transactional
    public void deactivateItem(String id, String employeeId) {
        InventoryItem item = findItemOrThrow(id);
        EmployeeProfile employee = findEmployeeOrThrow(employeeId);
        item.setIsActive(false);
        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        
        createAdjustment(item, employee, 0, AdjustmentType.DEACTIVATE, "Vô hiệu hóa vật tư (Xóa)");
        
        broadcastInventoryUpdate(response);
    }

    @Override
    @Transactional
    public InventoryCatalogueResponseDTO updateItemPrice(String id, BigDecimal unitPrice, String employeeId) {
        InventoryItem item = findItemOrThrow(id);
        EmployeeProfile employee = findEmployeeOrThrow(employeeId);
        item.setUnitPrice(unitPrice);
        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        
        createAdjustment(item, employee, 0, AdjustmentType.UPDATE, "Cập nhật giá bán thành: " + unitPrice + "đ");
        
        broadcastInventoryUpdate(response);
        return response;
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
                int currentQty = item.getStockQuantity();
                int targetQty = request.getQuantity();
                int diff = targetQty - currentQty;
                item.setStockQuantity(targetQty);
                createAdjustment(item, employee, diff, type, request.getReason());
            }
        }

        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        broadcastInventoryUpdate(response);
        return response;
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
                .description(item.getDescription())
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

    // ── NEW: Deactivated items & Reactivation ──

    @Override
    public List<InventoryCatalogueResponseDTO> getDeactivatedItems() {
        return inventoryRepo.findByIsActiveFalse().stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public void reactivateItem(String id, String employeeId) {
        InventoryItem item = inventoryRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vật tư: " + id));
        EmployeeProfile employee = findEmployeeOrThrow(employeeId);
        if (item.getIsActive()) {
            throw new RuntimeException("Vật tư đang hoạt động, không cần khôi phục");
        }
        item.setIsActive(true);
        InventoryCatalogueResponseDTO response = toResponse(inventoryRepo.save(item));
        
        createAdjustment(item, employee, 0, AdjustmentType.REACTIVATE, "Khôi phục hoạt động vật tư");
        
        broadcastInventoryUpdate(response);
    }

    // ── NEW: Global adjustment history ──

    @Override
    public List<InventoryAdjustmentResponseDTO> getAllAdjustments() {
        return adjustmentRepo.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toAdjustmentResponse)
                .toList();
    }

    private InventoryAdjustmentResponseDTO toAdjustmentResponse(InventoryAdjustment adj) {
        return InventoryAdjustmentResponseDTO.builder()
                .adjustmentId(adj.getAdjustmentId())
                .itemId(adj.getItem().getItemId())
                .itemName(adj.getItem().getItemName())
                .employeeId(adj.getEmployee().getUserId())
                .employeeName(adj.getEmployee().getFullName())
                .quantity(adj.getQuantity())
                .type(adj.getType().name())
                .description(adj.getDescription())
                .createdAt(adj.getCreatedAt())
                .build();
    }

    private void broadcastInventoryUpdate(InventoryCatalogueResponseDTO response) {
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    try {
                        messagingTemplate.convertAndSend("/topic/inventory-updates", response);
                    } catch (Exception e) {
                    }
                }
            });
        } else {
            try {
                messagingTemplate.convertAndSend("/topic/inventory-updates", response);
            } catch (Exception e) {
            }
        }
    }
}
