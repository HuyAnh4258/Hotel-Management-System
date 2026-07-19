package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.report.CostReport;
import com.hotel.hms.modules.booking_management.dto.report.FeedbackReport;
import com.hotel.hms.modules.booking_management.dto.report.OccupancyReport;
import com.hotel.hms.modules.booking_management.dto.report.RevenueReport;
import com.hotel.hms.modules.booking_management.service.ReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/revenue")
    public ResponseEntity<RevenueReport> getRevenueReport() {
        return ResponseEntity.ok(reportService.getRevenueReport());
    }

    @GetMapping("/cost")
    public ResponseEntity<CostReport> getCostReport() {
        return ResponseEntity.ok(reportService.getCostReport());
    }

    @GetMapping("/occupancy")
    public ResponseEntity<OccupancyReport> getOccupancyReport() {
        return ResponseEntity.ok(reportService.getOccupancyReport());
    }

    @GetMapping("/feedback")
    public ResponseEntity<FeedbackReport> getFeedbackReport() {
        return ResponseEntity.ok(reportService.getFeedbackReport());
    }
}
