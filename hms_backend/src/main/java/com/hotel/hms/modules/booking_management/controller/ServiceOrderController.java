package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.OrderDTO;
import com.hotel.hms.modules.booking_management.service.ServiceOrderService;
import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orders")
public class ServiceOrderController {

    private final ServiceOrderService orderService;

    public ServiceOrderController(ServiceOrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public ResponseEntity<List<OrderDTO>> getOrders(@RequestParam(name = "status", required = false) String status) {
        return ResponseEntity.ok(orderService.getOrdersByStatus(status));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<OrderDTO> updateOrderStatus(
            @PathVariable("id") String id,
            @RequestBody Map<String, String> payload
    ) {
        String newStatus = payload.get("status");
        return ResponseEntity.ok(orderService.updateOrderStatus(id, newStatus));
    }
}
