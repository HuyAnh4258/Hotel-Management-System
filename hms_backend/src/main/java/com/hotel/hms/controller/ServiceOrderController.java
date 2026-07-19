package com.hotel.hms.controller;

import com.hotel.hms.dto.CreateServiceOrderRequest;
import com.hotel.hms.dto.ServiceOrderSummary;
import com.hotel.hms.dto.ServiceSummary;
import com.hotel.hms.service.ServiceOrderService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/service-orders")
public class ServiceOrderController {
    private final ServiceOrderService serviceOrderService;

    public ServiceOrderController(ServiceOrderService serviceOrderService) {
        this.serviceOrderService = serviceOrderService;
    }

    @GetMapping("/services")
    public ResponseEntity<List<ServiceSummary>> getServices() {
        return ResponseEntity.ok(serviceOrderService.getActiveServices());
    }

    @GetMapping
    public ResponseEntity<List<ServiceOrderSummary>> getOrders() {
        return ResponseEntity.ok(serviceOrderService.getOrders());
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<List<ServiceOrderSummary>> getOrdersByBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(serviceOrderService.getOrdersByBooking(bookingId));
    }

    @PostMapping
    public ResponseEntity<ServiceOrderSummary> createOrder(@Valid @RequestBody CreateServiceOrderRequest request) {
        return ResponseEntity.ok(serviceOrderService.createOrder(request));
    }

    @PatchMapping("/{orderId}/cancel")
    public ResponseEntity<ServiceOrderSummary> cancelOrder(@PathVariable("orderId") String orderId) {
        return ResponseEntity.ok(serviceOrderService.cancelOrder(orderId));
    }

    @PatchMapping("/{orderId}/status")
    public ResponseEntity<ServiceOrderSummary> updateOrderStatus(
            @PathVariable("orderId") String orderId,
            @RequestParam(name = "status") String status
    ) {
        return ResponseEntity.ok(serviceOrderService.updateOrderStatus(orderId, status));
    }
}
