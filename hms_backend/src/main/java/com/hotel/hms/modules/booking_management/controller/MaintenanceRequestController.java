package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.MaintenanceRequestDTO;
import com.hotel.hms.modules.booking_management.entity.MaintenanceRequest;
import com.hotel.hms.modules.booking_management.service.MaintenanceRequestService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/maintenance")
public class MaintenanceRequestController {

    private final MaintenanceRequestService maintenanceRequestService;

    public MaintenanceRequestController(MaintenanceRequestService maintenanceRequestService) {
        this.maintenanceRequestService = maintenanceRequestService;
    }

    @PostMapping("/request")
    public ResponseEntity<MaintenanceRequest> createMaintenanceRequest(@RequestBody MaintenanceRequestDTO requestDTO) {
        MaintenanceRequest request = maintenanceRequestService.createMaintenanceRequest(requestDTO);
        return ResponseEntity.ok(request);
    }
}
