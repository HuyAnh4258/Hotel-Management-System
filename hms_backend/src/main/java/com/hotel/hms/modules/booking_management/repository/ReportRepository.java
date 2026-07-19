package com.hotel.hms.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Repository;

import com.hotel.hms.dto.report.RevenueReport.MonthlyData;
import com.hotel.hms.dto.report.CostReport;
import com.hotel.hms.dto.report.FeedbackReport.FeedbackItem;

@Repository
public class ReportRepository {

    @PersistenceContext
    private EntityManager entityManager;

    // ==========================================
    // REVENUE (From Payment table where Status = 'COMPLETED')
    // ==========================================

    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(Amount) FROM Payment WHERE Status = 'COMPLETED'";
        Query query = entityManager.createNativeQuery(sql);
        Object result = query.getSingleResult();
        return result != null ? new BigDecimal(result.toString()) : BigDecimal.ZERO;
    }

    public List<MonthlyData> getMonthlyRevenue(int limitMonths) {
        String sql = """
                SELECT DATE_FORMAT(PaidAt, '%Y-%m') AS month, SUM(Amount) AS total
                FROM Payment
                WHERE Status = 'COMPLETED'
                GROUP BY DATE_FORMAT(PaidAt, '%Y-%m')
                ORDER BY month DESC
                LIMIT :limit
                """;
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("limit", limitMonths);

        List<Object[]> rows = query.getResultList();
        List<MonthlyData> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(new MonthlyData(
                    row[0].toString(),
                    new BigDecimal(row[1].toString())
            ));
        }
        return list;
    }

    // ==========================================
    // COST (From Expense table)
    // ==========================================

    public BigDecimal getTotalCost() {
        String sql = "SELECT SUM(Amount) FROM Expense";
        Query query = entityManager.createNativeQuery(sql);
        Object result = query.getSingleResult();
        return result != null ? new BigDecimal(result.toString()) : BigDecimal.ZERO;
    }

    public List<CostReport.MonthlyData> getMonthlyCost(int limitMonths) {
        String sql = """
                SELECT DATE_FORMAT(CreatedAt, '%Y-%m') AS month, SUM(Amount) AS total
                FROM Expense
                GROUP BY DATE_FORMAT(CreatedAt, '%Y-%m')
                ORDER BY month DESC
                LIMIT :limit
                """;
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("limit", limitMonths);

        List<Object[]> rows = query.getResultList();
        List<CostReport.MonthlyData> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(new CostReport.MonthlyData(
                    row[0].toString(),
                    new BigDecimal(row[1].toString())
            ));
        }
        return list;
    }

    // ==========================================
    // OCCUPANCY (From Room table)
    // ==========================================

    public Object[] getRoomStatistics() {
        String sql = """
                SELECT 
                    COUNT(*) AS totalRooms,
                    SUM(CASE WHEN Status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupiedRooms,
                    SUM(CASE WHEN Status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenanceRooms,
                    SUM(CASE WHEN Status = 'AVAILABLE' THEN 1 ELSE 0 END) AS availableRooms
                FROM Room
                WHERE IsActive = 1
                """;
        Query query = entityManager.createNativeQuery(sql);
        return (Object[]) query.getSingleResult();
    }

    // ==========================================
    // FEEDBACK
    // ==========================================

    public double getAverageRating() {
        String sql = "SELECT AVG(Rating) FROM Feedback";
        Query query = entityManager.createNativeQuery(sql);
        Object result = query.getSingleResult();
        return result != null ? Double.parseDouble(result.toString()) : 0.0;
    }

    public int getTotalReviews() {
        String sql = "SELECT COUNT(*) FROM Feedback";
        Query query = entityManager.createNativeQuery(sql);
        Object result = query.getSingleResult();
        return result != null ? Integer.parseInt(result.toString()) : 0;
    }

    public List<FeedbackItem> getRecentFeedbacks(int limit) {
        String sql = """
                SELECT gp.FullName, f.Rating, f.Comment, f.CreatedAt
                FROM Feedback f
                JOIN Booking b ON f.BookingId = b.BookingId
                JOIN GuestProfile gp ON b.GuestId = gp.GuestId
                ORDER BY f.CreatedAt DESC
                LIMIT :limit
                """;
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("limit", limit);

        List<Object[]> rows = query.getResultList();
        List<FeedbackItem> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(new FeedbackItem(
                    row[0] != null ? row[0].toString() : "Unknown Guest",
                    Integer.parseInt(row[1].toString()),
                    row[2] != null ? row[2].toString() : "",
                    row[3] != null ? row[3].toString() : ""
            ));
        }
        return list;
    }
}
