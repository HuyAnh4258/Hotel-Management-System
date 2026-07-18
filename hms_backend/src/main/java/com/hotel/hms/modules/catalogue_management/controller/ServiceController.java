package com.hotel.hms.modules.catalogue_management.controller;

import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.service.ServiceServiceImpl;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class ServiceController {

    private final ServiceServiceImpl serviceService;

    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER', 'RECEPTIONIST', 'SERVICE_STAFF')")
    public ResponseEntity<List<ServiceResponseDTO>> getAll() {
        return ResponseEntity.ok(serviceService.getAll());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<ServiceResponseDTO> getById(@PathVariable("id") String id) {
        return ResponseEntity.ok(serviceService.getById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<ServiceResponseDTO> create(@Valid @RequestBody ServiceRequestDTO request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(serviceService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'MANAGER')")
    public ResponseEntity<ServiceResponseDTO> update(@PathVariable("id") String id,
                                                      @Valid @RequestBody ServiceRequestDTO request) {
        return ResponseEntity.ok(serviceService.update(id, request));
    }

    @PatchMapping("/{id}/unit-price")
    @PreAuthorize("hasRole('OWNER')")
    public ResponseEntity<ServiceResponseDTO> updatePrice(@PathVariable("id") String id,
                                                           @RequestBody Map<String, BigDecimal> body) {
        return ResponseEntity.ok(serviceService.updatePrice(id, body.get("unitPrice")));
    }

    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Void> deactivate(@PathVariable("id") String id) {
        serviceService.deactivate(id);
        return ResponseEntity.noContent().build();
    }
}
