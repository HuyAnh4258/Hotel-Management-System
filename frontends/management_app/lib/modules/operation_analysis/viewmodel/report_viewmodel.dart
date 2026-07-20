import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ReportApi {
  ReportApi._();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/reports';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/reports';
    } catch (_) {}
    return 'http://localhost:8080/api/reports';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<RevenueReport> getRevenueReport() async {
    final response = await _dio.get('$_baseUrl/revenue');
    return RevenueReport.fromJson(response.data);
  }

  static Future<CostReport> getCostReport() async {
    final response = await _dio.get('$_baseUrl/cost');
    return CostReport.fromJson(response.data);
  }

  static Future<OccupancyReport> getOccupancyReport() async {
    final response = await _dio.get('$_baseUrl/occupancy');
    return OccupancyReport.fromJson(response.data);
  }

  static Future<FeedbackReport> getFeedbackReport() async {
    final response = await _dio.get('$_baseUrl/feedback');
    return FeedbackReport.fromJson(response.data);
  }
}

// ================== MODELS ==================

class RevenueReport {
  final double totalRevenue;
  final List<MonthlyData> monthlyRevenue;

  RevenueReport({required this.totalRevenue, required this.monthlyRevenue});

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    return RevenueReport(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthlyRevenue'] as List<dynamic>?)
              ?.map((e) => MonthlyData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CostReport {
  final double totalCost;
  final List<MonthlyData> monthlyCost;

  CostReport({required this.totalCost, required this.monthlyCost});

  factory CostReport.fromJson(Map<String, dynamic> json) {
    return CostReport(
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      monthlyCost: (json['monthlyCost'] as List<dynamic>?)
              ?.map((e) => MonthlyData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MonthlyData {
  final String month;
  final double amount;

  MonthlyData({required this.month, required this.amount});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OccupancyReport {
  final int totalRooms;
  final int occupiedRooms;
  final int maintenanceRooms;
  final int availableRooms;
  final double occupancyRate;

  OccupancyReport({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.maintenanceRooms,
    required this.availableRooms,
    required this.occupancyRate,
  });

  factory OccupancyReport.fromJson(Map<String, dynamic> json) {
    return OccupancyReport(
      totalRooms: json['totalRooms'] ?? 0,
      occupiedRooms: json['occupiedRooms'] ?? 0,
      maintenanceRooms: json['maintenanceRooms'] ?? 0,
      availableRooms: json['availableRooms'] ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FeedbackReport {
  final double averageRating;
  final int totalReviews;
  final List<FeedbackItem> recentFeedbacks;

  FeedbackReport({
    required this.averageRating,
    required this.totalReviews,
    required this.recentFeedbacks,
  });

  factory FeedbackReport.fromJson(Map<String, dynamic> json) {
    return FeedbackReport(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      recentFeedbacks: (json['recentFeedbacks'] as List<dynamic>?)
              ?.map((e) => FeedbackItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class FeedbackItem {
  final String guestName;
  final int rating;
  final String comment;
  final String date;

  FeedbackItem({
    required this.guestName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      guestName: json['guestName'] ?? 'Khách',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
