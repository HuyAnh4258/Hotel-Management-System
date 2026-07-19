package com.hotel.hms.modules.catalogue_management.controller;

import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.entity.AdjustmentType;
import com.hotel.hms.modules.catalogue_management.service.IInventoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final IInventoryService inventoryService;

    // â”€â”€ ITEM (MANAGER only for mutations, OWNER read-only) â”€â”€â”€â”€â”€

    @GetMapping("/items")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<InventoryCatalogueResponseDTO>> getAllItems() {
        return ResponseEntity.ok(inventoryService.getAllItems());
    }

    @GetMapping("/items/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<InventoryCatalogueResponseDTO> getItemById(@PathVariable("id") String id) {
        return ResponseEntity.ok(inventoryService.getItemById(id));
    }

    @PostMapping("/items")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<InventoryCatalogueResponseDTO> createItem(
            @Valid @RequestBody InventoryCatalogueRequestDTO request,
            @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(inventoryService.createInventoryItem(request, user.getUsername()));
    }

    @PutMapping("/items/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<InventoryCatalogueResponseDTO> updateItem(
            @PathVariable("id") String id,
            @Valid @RequestBody InventoryCatalogueRequestDTO request,
            @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(inventoryService.updateItemDetails(id, request, user.getUsername()));
    }

    @PatchMapping("/items/{id}/deactivate")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<Void> deactivateItem(
            @PathVariable("id") String id,
            @AuthenticationPrincipal UserDetails user) {
        inventoryService.deactivateItem(id, user.getUsername());
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/items/{id}/unit-price")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<InventoryCatalogueResponseDTO> updateItemPrice(
            @PathVariable("id") String id,
            @RequestBody Map<String, BigDecimal> body,
            @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(inventoryService.updateItemPrice(id, body.get("unitPrice"), user.getUsername()));
    }

    // â”€â”€ ADJUSTMENT (RBAC enforced per type) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    @PostMapping("/adjustments")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER', 'SERVICE_STAFF', 'HOUSEKEEPER')")
    public ResponseEntity<InventoryCatalogueResponseDTO> processAdjustment(
            @Valid @RequestBody InventoryAdjustmentRequestDTO request,
            @AuthenticationPrincipal UserDetails user) {

        AdjustmentType type = request.getType();
        String role = user.getAuthorities().iterator().next().getAuthority();

        switch (type) {
            case RESTOCK, RECONCILE, LOSS -> {
                if (!role.contains("MANAGER")) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
            }
            case CONSUME -> {
                if (!role.contains("MANAGER") && !role.contains("SERVICE_STAFF")) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
            }
            case DAMAGE -> {
                if (!role.contains("MANAGER") && !role.contains("SERVICE_STAFF")
                        && !role.contains("HOUSEKEEPER")) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
            }
            case AUTO_SELL -> {
                // System-only â€” no human role allowed
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(inventoryService.processInventoryAdjustment(request, user.getUsername()));
    }

    // â”€â”€ HISTORY & REPORTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    @GetMapping("/items/{id}/history")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<?>> getItemAdjustmentHistory(@PathVariable("id") String id) {
        return ResponseEntity.ok(inventoryService.getItemAdjustmentHistory(id));
    }

    @GetMapping("/low-stock")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<InventoryCatalogueResponseDTO>> getLowStockItems() {
        return ResponseEntity.ok(inventoryService.getLowStockItems());
    }

    @GetMapping("/expenses/report")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<?>> getExpenseReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fromDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime toDate) {
        return ResponseEntity.ok(inventoryService.getExpenseReport(fromDate, toDate));
    }

    // â”€â”€ DEACTIVATED ITEMS & REACTIVATION â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    @GetMapping("/items/deactivated")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<InventoryCatalogueResponseDTO>> getDeactivatedItems() {
        return ResponseEntity.ok(inventoryService.getDeactivatedItems());
    }

    @PatchMapping("/items/{id}/reactivate")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<Void> reactivateItem(
            @PathVariable("id") String id,
            @AuthenticationPrincipal UserDetails user) {
        inventoryService.reactivateItem(id, user.getUsername());
        return ResponseEntity.noContent().build();
    }

    // â”€â”€ GLOBAL ADJUSTMENT HISTORY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    @GetMapping("/adjustments")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<List<InventoryAdjustmentResponseDTO>> getAllAdjustments() {
        return ResponseEntity.ok(inventoryService.getAllAdjustments());
    }
}
