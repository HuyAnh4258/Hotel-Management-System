package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.OrderDTO;
import com.hotel.hms.modules.booking_management.entity.ServiceOrder;
import com.hotel.hms.modules.booking_management.repository.ServiceOrderRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ServiceOrderService {

    private final ServiceOrderRepository orderRepository;

    public ServiceOrderService(ServiceOrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByStatus(String status) {
        // If status is "ALL", fetch all. Otherwise, fetch by status.
        String filterStatus = (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status)) 
                                ? null 
                                : status.toUpperCase();
                                
        List<ServiceOrder> orders = orderRepository.findOrdersByStatus(filterStatus);
        
        return orders.stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Transactional
    public OrderDTO updateOrderStatus(String orderId, String newStatus) {
        if (newStatus == null || newStatus.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status is required");
        }

        ServiceOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));

        order.setStatus(newStatus.toUpperCase());
        // For "Consume Item" logic: we might also update InventoryItem here if newStatus == COMPLETED
        // but for now we just change the state as requested by the diagrams.

        order = orderRepository.save(order);
        
        // Reload to get associations if needed, but since we just update status, 
        // we can fetch it again or map directly.
        // It's safer to use the existing object, though guest might not be fetched.
        // We'll refetch it to ensure full data mapping:
        ServiceOrder updatedOrder = orderRepository.findOrdersByStatus(null).stream()
                .filter(o -> o.getOrderId().equals(orderId))
                .findFirst()
                .orElse(order);

        return mapToDTO(updatedOrder);
    }

    private OrderDTO mapToDTO(ServiceOrder order) {
        String guestName = "Unknown";
        if (order.getBooking() != null && order.getBooking().getGuest() != null) {
            guestName = order.getBooking().getGuest().getFullName();
        }

        return new OrderDTO(
                order.getOrderId(),
                order.getEmployeeId(),
                order.getBookingId(),
                guestName,
                order.getTotalAmount(),
                order.getStatus(),
                order.getOrderedAt() != null ? order.getOrderedAt().toString() : ""
        );
    }
}
