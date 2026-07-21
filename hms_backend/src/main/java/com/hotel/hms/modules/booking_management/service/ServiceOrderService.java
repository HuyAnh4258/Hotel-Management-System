package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.CreateServiceOrderRequest;
import com.hotel.hms.modules.booking_management.dto.OrderDTO;
import com.hotel.hms.modules.booking_management.dto.ServiceOrderLineRequest;
import com.hotel.hms.modules.booking_management.dto.ServiceOrderLineSummary;
import com.hotel.hms.modules.booking_management.dto.ServiceOrderSummary;
import com.hotel.hms.modules.booking_management.dto.ServiceSummary;
import com.hotel.hms.modules.booking_management.entity.Booking;
import com.hotel.hms.modules.booking_management.entity.HotelService;
import com.hotel.hms.modules.booking_management.entity.ServiceOrder;
import com.hotel.hms.modules.booking_management.repository.BookingRepository;
import com.hotel.hms.modules.booking_management.repository.HotelServiceRepository;
import com.hotel.hms.modules.booking_management.repository.ServiceOrderRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ServiceOrderService {

    private static final List<String> UPDATE_STATUSES = List.of(
            "PENDING",
            "APPROVED",
            "IN_PROGRESS",
            "COMPLETED",
            "CANCELLED"
    );

    private final ServiceOrderRepository orderRepository;
    private final BookingRepository bookingRepository;
    private final HotelServiceRepository hotelServiceRepository;

    @PersistenceContext
    private EntityManager entityManager;

    public ServiceOrderService(
            ServiceOrderRepository orderRepository,
            BookingRepository bookingRepository,
            HotelServiceRepository hotelServiceRepository
    ) {
        this.orderRepository = orderRepository;
        this.bookingRepository = bookingRepository;
        this.hotelServiceRepository = hotelServiceRepository;
    }

    // ================================================================
    // HEAD: Logic đang chạy ổn định cho Service Staff frontend
    // ================================================================

    @Transactional(readOnly = true)
    public List<OrderDTO> getOrdersByStatus(String status) {
        String filterStatus = (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status))
                                ? null
                                : status.toUpperCase();

        List<ServiceOrder> orders = orderRepository.findOrdersByStatus(filterStatus);

        return orders.stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Transactional
    public OrderDTO updateOrderStatusLegacy(String orderId, String newStatus) {
        if (newStatus == null || newStatus.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status is required");
        }

        ServiceOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));

        String normalizedStatus = newStatus.trim().toUpperCase();
        if (!UPDATE_STATUSES.contains(normalizedStatus)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported order status");
        }
        validateStatusTransition(order.getStatus(), normalizedStatus);

        order.setStatus(normalizedStatus);
        order = orderRepository.save(order);

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

    // ================================================================
    // Branch Thang: Logic mới cho booking app service orders
    // ================================================================

    @Transactional(readOnly = true)
    public List<ServiceSummary> getActiveServices() {
        return hotelServiceRepository.findByIsActiveTrueOrderByServiceNameAsc().stream()
                .map(this::toServiceSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ServiceOrderSummary> getOrders() {
        return getOrderRows(null).stream()
                .map(this::toOrderSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ServiceOrderSummary> getOrdersByBooking(String bookingId) {
        return getOrderRows(bookingId).stream()
                .map(this::toOrderSummary)
                .toList();
    }

    @Transactional
    public ServiceOrderSummary createOrder(CreateServiceOrderRequest request) {
        Booking booking = bookingRepository.findById(request.bookingId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        ensureBookingCanAcceptOrder(booking);

        Map<String, Integer> requestedQuantities = normalizeRequestedServices(request.services());
        List<ServiceOrderLineSummary> lines = new ArrayList<>();
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (Map.Entry<String, Integer> entry : requestedQuantities.entrySet()) {
            HotelService service = hotelServiceRepository.findById(entry.getKey())
                    .filter(value -> value.getIsActive() == null || value.getIsActive())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND,
                            "Service not found or inactive: " + entry.getKey()
                    ));

            BigDecimal price = service.getPrice() == null ? BigDecimal.ZERO : service.getPrice();
            int quantity = entry.getValue();
            BigDecimal lineTotal = price.multiply(BigDecimal.valueOf(quantity));
            totalAmount = totalAmount.add(lineTotal);

            lines.add(new ServiceOrderLineSummary(
                    service.getServiceId(),
                    service.getServiceName(),
                    quantity,
                    price,
                    lineTotal
            ));
        }

        String orderId = generateId("ORD", 20);
        LocalDateTime orderedAt = LocalDateTime.now();

        entityManager.createNativeQuery("""
                INSERT INTO `Order` (OrderId, EmployeeId, BookingId, TotalAmount, Status, OrderedAt)
                VALUES (:orderId, :employeeId, :bookingId, :totalAmount, 'PENDING', :orderedAt)
                """)
                .setParameter("orderId", orderId)
                .setParameter("employeeId", findOrCreateDefaultEmployeeUserId())
                .setParameter("bookingId", booking.getBookingId())
                .setParameter("totalAmount", totalAmount)
                .setParameter("orderedAt", orderedAt)
                .executeUpdate();

        for (ServiceOrderLineSummary line : lines) {
            entityManager.createNativeQuery("""
                    INSERT INTO ServiceOrder_Service (ServiceId, OrderId, Quantity, PriceAtOrder)
                    VALUES (:serviceId, :orderId, :quantity, :priceAtOrder)
                    """)
                    .setParameter("serviceId", line.serviceId())
                    .setParameter("orderId", orderId)
                    .setParameter("quantity", line.quantity())
                    .setParameter("priceAtOrder", line.priceAtOrder())
                    .executeUpdate();
        }

        recalculateAndStoreBookingTotal(booking.getBookingId());
        return getOrder(orderId);
    }

    @Transactional
    public ServiceOrderSummary cancelOrder(String orderId) {
        ServiceOrderSummary order = getOrder(orderId);
        String currentStatus = order.status() == null ? "" : order.status().trim().toUpperCase();
        if ("COMPLETED".equals(currentStatus)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Completed order cannot be cancelled");
        }
        if ("CANCELLED".equals(currentStatus)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Order is already cancelled");
        }
        if (!List.of("PENDING", "APPROVED", "IN_PROGRESS").contains(currentStatus)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Order cannot be cancelled in current status");
        }
        return updateOrderStatus(orderId, "CANCELLED");
    }

    @Transactional
    public ServiceOrderSummary updateOrderStatus(String orderId, String status) {
        String normalizedStatus = status == null ? "" : status.trim().toUpperCase();
        if (!UPDATE_STATUSES.contains(normalizedStatus)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported order status");
        }
        ServiceOrderSummary currentOrder = getOrder(orderId);
        validateStatusTransition(currentOrder.status(), normalizedStatus);

        if ("COMPLETED".equals(normalizedStatus) && !"COMPLETED".equals(currentOrder.status() == null ? "" : currentOrder.status().trim().toUpperCase())) {
            deductInventoryForOrder(orderId);
        }

        int updated = entityManager.createNativeQuery("""
                UPDATE `Order`
                SET Status = :status
                WHERE OrderId = :orderId
                """)
                .setParameter("status", normalizedStatus)
                .setParameter("orderId", orderId)
                .executeUpdate();

        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found");
        }

        recalculateAndStoreBookingTotal(currentOrder.bookingId());
        return getOrder(orderId);
    }

    private void validateStatusTransition(String currentStatus, String nextStatus) {
        String current = currentStatus == null ? "" : currentStatus.trim().toUpperCase();
        if (current.equals(nextStatus)) {
            return;
        }

        boolean valid = switch (current) {
            case "PENDING" -> List.of("APPROVED", "CANCELLED").contains(nextStatus);
            case "APPROVED" -> List.of("IN_PROGRESS", "CANCELLED").contains(nextStatus);
            case "IN_PROGRESS" -> List.of("COMPLETED", "CANCELLED").contains(nextStatus);
            default -> false;
        };

        if (!valid) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid order status transition from " + current + " to " + nextStatus
            );
        }
    }

    // ================================================================
    // Private helpers
    // ================================================================

    private void deductInventoryForOrder(String orderId) {
        String username = "system";
        try {
            org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (auth != null) {
                Object principal = auth.getPrincipal();
                if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
                    username = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
                } else {
                    username = principal.toString();
                }
            }
        } catch (Exception e) {}

        String employeeId = null;
        try {
            java.util.List<String> ids = entityManager.createNativeQuery("SELECT UserId FROM `User` WHERE Username = :uname")
                .setParameter("uname", username)
                .getResultList();
            if (!ids.isEmpty()) employeeId = ids.get(0);
        } catch(Exception e) {
            e.printStackTrace();
        }

        if (employeeId == null) {
            System.err.println("WARN: Could not resolve employeeId for username: " + username);
            return; // Cannot adjust inventory without a valid employee
        }

        java.util.List<Object[]> deductions = entityManager.createNativeQuery("""
            SELECT sir.InventoryItemId, SUM(sos.Quantity * sir.QuantityRequired)
            FROM ServiceOrder_Service sos
            JOIN Service_Inventory_Recipe sir ON sos.ServiceId = sir.ServiceId
            WHERE sos.OrderId = :orderId
            GROUP BY sir.InventoryItemId
        """).setParameter("orderId", orderId).getResultList();

        for (Object[] row : deductions) {
            String itemId = (String) row[0];
            Number totalDeduct = (Number) row[1];
            if (totalDeduct == null) continue;
            int deductQty = totalDeduct.intValue();
            if (deductQty <= 0) continue;
            
            entityManager.createNativeQuery("""
                UPDATE InventoryItem
                SET StockQuantity = GREATEST(0, StockQuantity - :qty)
                WHERE ItemId = :itemId
            """)
            .setParameter("qty", deductQty)
            .setParameter("itemId", itemId)
            .executeUpdate();

            String adjId = "ADJ-" + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyMMddHHmmss")) + "-" + String.format("%04d", (int)(Math.random() * 10000));
            try {
                entityManager.createNativeQuery("""
                    INSERT INTO InventoryAdjustment (AdjustmentId, ItemId, EmployeeId, Quantity, Type, Description)
                    VALUES (:adjId, :itemId, :empId, :qty, 'CONSUME', :desc)
                """)
                .setParameter("adjId", adjId)
                .setParameter("itemId", itemId)
                .setParameter("empId", employeeId)
                .setParameter("qty", -deductQty)
                .setParameter("desc", "Bán kèm dịch vụ (Order " + orderId + ")")
                .executeUpdate();
            } catch (Exception e) {
                // Ignore failure on audit log insert
            }
        }
    }

    private ServiceOrderSummary getOrder(String orderId) {
        try {
            Object[] row = (Object[]) entityManager.createNativeQuery("""
                    SELECT o.OrderId, o.BookingId, gp.FullName, gp.Phone, o.Status, o.TotalAmount, o.OrderedAt
                    FROM `Order` o
                    JOIN Booking b ON b.BookingId = o.BookingId
                    JOIN GuestProfile gp ON gp.GuestId = b.GuestId
                    WHERE o.OrderId = :orderId
                    """)
                    .setParameter("orderId", orderId)
                    .getSingleResult();
            return toOrderSummary(row);
        } catch (NoResultException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found");
        }
    }

    @SuppressWarnings("unchecked")
    private List<Object[]> getOrderRows(String bookingId) {
        if (bookingId == null || bookingId.isBlank()) {
            return entityManager.createNativeQuery("""
                    SELECT o.OrderId, o.BookingId, gp.FullName, gp.Phone, o.Status, o.TotalAmount, o.OrderedAt
                    FROM `Order` o
                    JOIN Booking b ON b.BookingId = o.BookingId
                    JOIN GuestProfile gp ON gp.GuestId = b.GuestId
                    ORDER BY o.OrderedAt DESC
                    """)
                    .getResultList();
        }

        return entityManager.createNativeQuery("""
                SELECT o.OrderId, o.BookingId, gp.FullName, gp.Phone, o.Status, o.TotalAmount, o.OrderedAt
                FROM `Order` o
                JOIN Booking b ON b.BookingId = o.BookingId
                JOIN GuestProfile gp ON gp.GuestId = b.GuestId
                WHERE o.BookingId = :bookingId
                ORDER BY o.OrderedAt DESC
                """)
                .setParameter("bookingId", bookingId)
                .getResultList();
    }

    private ServiceOrderSummary toOrderSummary(Object[] row) {
        String orderId = value(row[0]);
        return new ServiceOrderSummary(
                orderId,
                value(row[1]),
                value(row[2]),
                value(row[3]),
                value(row[4]),
                toBigDecimal(row[5]),
                toLocalDateTime(row[6]),
                getOrderLines(orderId)
        );
    }

    @SuppressWarnings("unchecked")
    private List<ServiceOrderLineSummary> getOrderLines(String orderId) {
        List<Object[]> rows = entityManager.createNativeQuery("""
                SELECT s.ServiceId, s.ServiceName, os.Quantity, os.PriceAtOrder
                FROM ServiceOrder_Service os
                JOIN Service s ON s.ServiceId = os.ServiceId
                WHERE os.OrderId = :orderId
                ORDER BY s.ServiceName
                """)
                .setParameter("orderId", orderId)
                .getResultList();

        return rows.stream()
                .map(row -> {
                    int quantity = ((Number) row[2]).intValue();
                    BigDecimal price = toBigDecimal(row[3]);
                    return new ServiceOrderLineSummary(
                            value(row[0]),
                            value(row[1]),
                            quantity,
                            price,
                            price.multiply(BigDecimal.valueOf(quantity))
                    );
                })
                .toList();
    }

    private Map<String, Integer> normalizeRequestedServices(List<ServiceOrderLineRequest> services) {
        if (services == null || services.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "services is required");
        }

        Map<String, Integer> quantities = new LinkedHashMap<>();
        for (ServiceOrderLineRequest line : services) {
            String serviceId = line.serviceId() == null ? "" : line.serviceId().trim();
            if (serviceId.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "serviceId is required");
            }
            if (line.quantity() <= 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "quantity must be greater than zero");
            }
            quantities.merge(serviceId, line.quantity(), Integer::sum);
        }
        return quantities;
    }

    private void ensureBookingCanAcceptOrder(Booking booking) {
        String status = booking.getStatus() == null ? "" : booking.getStatus().trim().toUpperCase();
        if (!List.of("PENDING", "CONFIRMED", "CHECKED_IN", "CANCEL_REJECTED").contains(status)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Only active bookings can create service orders"
            );
        }

        Number roomBookingCount = (Number) entityManager.createNativeQuery("""
                SELECT COUNT(*)
                FROM RoomBooking
                WHERE BookingId = :bookingId
                  AND UPPER(Status) <> 'CANCELLED'
                  AND UPPER(Status) <> 'RELEASED'
                """)
                .setParameter("bookingId", booking.getBookingId())
                .getSingleResult();

        if (roomBookingCount.longValue() == 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Booking must have at least one active room before creating service orders"
            );
        }
    }

    private void recalculateAndStoreBookingTotal(String bookingId) {
        Object roomAmount = entityManager.createNativeQuery("""
                SELECT COALESCE(SUM(PriceAtBooking), 0)
                FROM RoomBooking
                WHERE BookingId = :bookingId
                """)
                .setParameter("bookingId", bookingId)
                .getSingleResult();

        Object serviceAmount = entityManager.createNativeQuery("""
                SELECT COALESCE(SUM(TotalAmount), 0)
                FROM `Order`
                WHERE BookingId = :bookingId
                  AND UPPER(Status) <> 'CANCELLED'
                """)
                .setParameter("bookingId", bookingId)
                .getSingleResult();

        entityManager.createNativeQuery("""
                UPDATE Booking
                SET TotalAmount = :totalAmount
                WHERE BookingId = :bookingId
                """)
                .setParameter("totalAmount", toBigDecimal(roomAmount).add(toBigDecimal(serviceAmount)))
                .setParameter("bookingId", bookingId)
                .executeUpdate();
    }

    private String findOrCreateDefaultEmployeeUserId() {
        try {
            return entityManager.createNativeQuery("""
                    SELECT UserId
                    FROM EmployeeProfile
                    ORDER BY EmployeeId
                    LIMIT 1
                    """)
                    .getSingleResult()
                    .toString();
        } catch (NoResultException e) {
            String employeeId = generateId("EMP", 12);
            entityManager.createNativeQuery("""
                    INSERT INTO `User` (UserId, Username, Email, HashedPassword, IsActive, CreatedAt)
                    VALUES (:userId, :username, :email, 'SERVICE-ORDER-STAFF', 1, NOW())
                    """)
                    .setParameter("userId", employeeId)
                    .setParameter("username", "service_staff_" + employeeId)
                    .setParameter("email", "service_staff_" + employeeId + "@hms.local")
                    .executeUpdate();

            entityManager.createNativeQuery("""
                    INSERT INTO EmployeeProfile (UserId, EmployeeId, FullName, Phone, Salary, HireDate)
                    VALUES (:userId, :employeeId, 'Default Service Staff', :phone, 0, :hireDate)
                    """)
                    .setParameter("userId", employeeId)
                    .setParameter("employeeId", employeeId)
                    .setParameter("phone", createPhoneSuffix())
                    .setParameter("hireDate", LocalDate.now())
                    .executeUpdate();

            return employeeId;
        }
    }

    private String createPhoneSuffix() {
        String digits = String.valueOf(Math.abs(System.nanoTime()));
        return ("09" + digits).substring(0, 10);
    }

    private ServiceSummary toServiceSummary(HotelService service) {
        return new ServiceSummary(
                service.getServiceId(),
                service.getServiceName(),
                service.getDescription(),
                service.getPrice()
        );
    }

    private String generateId(String prefix, int maxLength) {
        StringBuilder value = new StringBuilder(prefix);
        String digits = String.valueOf(System.currentTimeMillis());

        for (int i = digits.length() - 1; i >= 0 && value.length() < maxLength; i--) {
            value.append(digits.charAt(i));
        }

        while (value.length() < maxLength) {
            value.append((char) ('0' + Math.abs((int) System.nanoTime()) % 10));
        }

        return value.substring(0, maxLength);
    }

    private String value(Object value) {
        return value == null ? "" : value.toString();
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }
        return BigDecimal.ZERO;
    }

    private LocalDateTime toLocalDateTime(Object value) {
        if (value instanceof LocalDateTime localDateTime) {
            return localDateTime;
        }
        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }
        return null;
    }
}
