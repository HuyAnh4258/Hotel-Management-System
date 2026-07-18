package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.catalogue_management.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface IExpenseRepository extends JpaRepository<Expense, String> {

    List<Expense> findByAdjustment_AdjustmentId(String adjustmentId);

    List<Expense> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.createdAt BETWEEN :from AND :to")
    BigDecimal calculateTotalExpense(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);
}
