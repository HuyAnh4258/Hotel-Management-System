import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class OrderApi {
  OrderApi._();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/orders';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/orders';
    } catch (_) {}
    return 'http://localhost:8080/api/orders';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch orders by status (e.g., "PENDING", "IN_PROGRESS", "COMPLETED", "ALL")
  static Future<List<OrderModel>> getOrders(String status) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {'status': status},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Update order status
  static Future<OrderModel> updateStatus(String orderId, String newStatus) async {
    final response = await _dio.put(
      '$_baseUrl/$orderId/status',
      data: {'status': newStatus},
    );
    return OrderModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

// ================== MODELS ==================

class OrderModel {
  final String orderId;
  final String employeeId;
  final String bookingId;
  final String guestName;
  final double totalAmount;
  final String status;
  final String orderedAt;

  OrderModel({
    required this.orderId,
    required this.employeeId,
    required this.bookingId,
    required this.guestName,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? 'Unknown',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      orderedAt: json['orderedAt']?.toString() ?? '',
    );
  }
}
