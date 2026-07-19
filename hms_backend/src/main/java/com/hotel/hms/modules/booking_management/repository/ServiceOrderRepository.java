package com.hotel.hms.modules.booking_management.repository;

import com.hotel.hms.modules.booking_management.entity.ServiceOrder;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ServiceOrderRepository extends JpaRepository<ServiceOrder, String> {

    @Query("""
            SELECT o FROM ServiceOrder o
            JOIN FETCH o.booking b
            JOIN FETCH b.guest g
            WHERE (:status IS NULL OR o.status = :status)
            ORDER BY o.orderedAt DESC
            """)
    List<ServiceOrder> findOrdersByStatus(@Param("status") String status);
}
