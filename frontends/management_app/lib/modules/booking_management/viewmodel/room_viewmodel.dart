import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class RoomApi {
  RoomApi._();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/rooms';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/rooms';
    } catch (_) {}
    return 'http://localhost:8080/api/rooms';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<RoomModel>> getRooms(String status) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {'status': status},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<RoomModel> updateStatus(String roomId, String newStatus) async {
    final response = await _dio.put(
      '$_baseUrl/$roomId/status',
      data: {'status': newStatus},
    );
    return RoomModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
  static Future<void> createMaintenanceRequest(String roomId, String reporterId, String issueType, String description) async {
    final baseUrl = _baseUrl.replaceAll('/rooms', '/maintenance/request');
    await _dio.post(
      baseUrl,
      data: {
        'roomId': roomId,
        'reporterId': reporterId,
        'issueType': issueType,
        'description': description,
      },
    );
  }
}

// ================== MODELS ==================

class RoomModel {
  final String roomId;
  final String roomName;
  final String roomTypeName;
  final int floorNumber;
  final String status;
  final String description;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.roomTypeName,
    required this.floorNumber,
    required this.status,
    required this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
      roomTypeName: json['roomTypeName']?.toString() ?? '',
      floorNumber: json['floorNumber'] as int? ?? 0,
      status: json['status']?.toString() ?? 'AVAILABLE',
      description: json['description']?.toString() ?? '',
    );
  }
}
