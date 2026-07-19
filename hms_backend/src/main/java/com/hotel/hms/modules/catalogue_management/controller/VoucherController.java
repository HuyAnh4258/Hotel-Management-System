package com.hotel.hms.modules.catalogue_management.controller;

import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueRequestDTO;
import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueResponseDTO;
import com.hotel.hms.modules.catalogue_management.service.IVoucherService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vouchers")
@RequiredArgsConstructor
public class VoucherController {

    private final IVoucherService voucherService;

    // ─── GET ALL ─────────────────────────────────────────────────

    @GetMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<List<VoucherCatalogueResponseDTO>> getAllVouchers() {
        return ResponseEntity.ok(voucherService.getAllItems());
    }

    // ─── GET BY ID ───────────────────────────────────────────────

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<VoucherCatalogueResponseDTO> getVoucherById(@PathVariable("id") String id) {
        return ResponseEntity.ok(voucherService.getVoucherById(id));
    }

    // ─── CREATE ──────────────────────────────────────────────────

    @PostMapping
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<VoucherCatalogueResponseDTO> createVoucher(
            @Valid @RequestBody VoucherCatalogueRequestDTO request,
            @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(voucherService.createVoucherItem(request, user.getUsername()));
    }

    // ─── UPDATE ──────────────────────────────────────────────────

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<VoucherCatalogueResponseDTO> updateVoucher(
            @PathVariable("id") String id,
            @Valid @RequestBody VoucherCatalogueRequestDTO request) {
        return ResponseEntity.ok(voucherService.updateVoucherDetails(id, request));
    }

    // ─── SOFT DELETE ─────────────────────────────────────────────

    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<Void> deactivateVoucher(@PathVariable("id") String id) {
        voucherService.deactivateVoucherItem(id);
        return ResponseEntity.noContent().build();
    }
}
