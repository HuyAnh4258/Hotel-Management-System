package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.OrderDTO;
import com.hotel.hms.modules.booking_management.dto.CreateServiceOrderRequest;
import com.hotel.hms.modules.booking_management.dto.ServiceOrderSummary;
import com.hotel.hms.modules.booking_management.dto.ServiceSummary;
import com.hotel.hms.modules.booking_management.service.ServiceOrderService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
public class ServiceOrderController {

    private final ServiceOrderService orderService;

    public ServiceOrderController(ServiceOrderService orderService) {
        this.orderService = orderService;
    }

    // --- HEAD: API đang chạy ổn định cho Service Staff frontend ---
    @GetMapping
    public ResponseEntity<List<OrderDTO>> getOrdersByStatus(@RequestParam(name = "status", required = false) String status) {
        return ResponseEntity.ok(orderService.getOrdersByStatus(status));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<OrderDTO> updateOrderStatusLegacy(
            @PathVariable("id") String id,
            @RequestBody Map<String, String> payload
    ) {
        String newStatus = payload.get("status");
        return ResponseEntity.ok(orderService.updateOrderStatusLegacy(id, newStatus));
    }

    // --- Branch Thang: API mới cho booking app ---
    @GetMapping("/services")
    public ResponseEntity<List<ServiceSummary>> getServices() {
        return ResponseEntity.ok(orderService.getActiveServices());
    }

    @GetMapping("/list")
    public ResponseEntity<List<ServiceOrderSummary>> getOrdersList() {
        return ResponseEntity.ok(orderService.getOrders());
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<List<ServiceOrderSummary>> getOrdersByBooking(@PathVariable("bookingId") String bookingId) {
        return ResponseEntity.ok(orderService.getOrdersByBooking(bookingId));
    }

    @PostMapping
    public ResponseEntity<ServiceOrderSummary> createOrder(@Valid @RequestBody CreateServiceOrderRequest request) {
        return ResponseEntity.ok(orderService.createOrder(request));
    }

    @PatchMapping("/{orderId}/cancel")
    public ResponseEntity<ServiceOrderSummary> cancelOrder(@PathVariable("orderId") String orderId) {
        return ResponseEntity.ok(orderService.cancelOrder(orderId));
    }

    @PatchMapping("/{orderId}/status")
    public ResponseEntity<ServiceOrderSummary> updateOrderStatusPatch(
            @PathVariable("orderId") String orderId,
            @RequestParam(name = "status") String status
    ) {
        return ResponseEntity.ok(orderService.updateOrderStatus(orderId, status));
    }
}
