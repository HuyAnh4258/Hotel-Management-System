package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.report.CostReport;
import com.hotel.hms.modules.booking_management.dto.report.FeedbackReport;
import com.hotel.hms.modules.booking_management.dto.report.OccupancyReport;
import com.hotel.hms.modules.booking_management.dto.report.RevenueReport;
import com.hotel.hms.modules.booking_management.repository.ReportRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReportService {

    private final ReportRepository reportRepository;

    public ReportService(ReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    @Transactional(readOnly = true)
    public RevenueReport getRevenueReport() {
        return new RevenueReport(
                reportRepository.getTotalRevenue(),
                reportRepository.getMonthlyRevenue(6) // Lấy 6 tháng gần nhất
        );
    }

    @Transactional(readOnly = true)
    public CostReport getCostReport() {
        return new CostReport(
                reportRepository.getTotalCost(),
                reportRepository.getMonthlyCost(6)
        );
    }

    @Transactional(readOnly = true)
    public OccupancyReport getOccupancyReport() {
        Object[] stats = reportRepository.getRoomStatistics();
        int total = Integer.parseInt(stats[0].toString());
        int occupied = Integer.parseInt(stats[1].toString());
        int maintenance = Integer.parseInt(stats[2].toString());
        int available = Integer.parseInt(stats[3].toString());
        
        double rate = total > 0 ? ((double) occupied / total) * 100 : 0.0;

        return new OccupancyReport(total, occupied, maintenance, available, Math.round(rate * 10.0) / 10.0);
    }

    @Transactional(readOnly = true)
    public FeedbackReport getFeedbackReport() {
        double avg = reportRepository.getAverageRating();
        return new FeedbackReport(
                Math.round(avg * 10.0) / 10.0,
                reportRepository.getTotalReviews(),
                reportRepository.getRecentFeedbacks(10) // Lấy 10 feedback mới nhất
        );
    }
}
