import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:hms_shared/auth/token_storage.dart';

/// API client and data models for Account Management.
class AccountApi {
  AccountApi._();

  static String get _baseUrl {
    // Desktop (Windows/macOS/Linux) or Web → localhost
    // Android Emulator → 10.0.2.2
    if (kIsWeb) return 'http://localhost:8080/api/accounts';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/accounts';
    } catch (_) {}
    return 'http://localhost:8080/api/accounts';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage().getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

  /// GET /api/accounts?search=&role=
  static Future<List<AccountModel>> getAccounts({
    String? search,
    String? role,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (role != null && role.isNotEmpty) params['role'] = role;

    final response = await _dio.get(
      _baseUrl,
      queryParameters: params.isEmpty ? null : params,
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /api/accounts/{id}
  static Future<AccountModel> getAccountById(String id) async {
    final response = await _dio.get('$_baseUrl/$id');
    return AccountModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// POST /api/accounts
  static Future<AccountModel> createAccount(CreateAccountPayload payload) async {
    final response = await _dio.post(_baseUrl, data: payload.toJson());
    return AccountModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// PUT /api/accounts/{id}
  static Future<AccountModel> updateAccount(
    String id,
    UpdateAccountPayload payload,
  ) async {
    final response = await _dio.put('$_baseUrl/$id', data: payload.toJson());
    return AccountModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// PUT /api/accounts/{id}/deactivate
  static Future<AccountModel> deactivateAccount(String id) async {
    final response = await _dio.put('$_baseUrl/$id/deactivate');
    return AccountModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// PUT /api/accounts/{id}/activate
  static Future<AccountModel> activateAccount(String id) async {
    final response = await _dio.put('$_baseUrl/$id/activate');
    return AccountModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

class AccountModel {
  AccountModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.employeeId,
    required this.fullName,
    required this.phone,
    this.salary,
    required this.hireDate,
    required this.roleName,
  });

  final String userId;
  final String username;
  final String email;
  final bool isActive;
  final String createdAt;
  final String employeeId;
  final String fullName;
  final String phone;
  final double? salary;
  final String hireDate;
  final String roleName;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['isActive'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      salary: (json['salary'] as num?)?.toDouble(),
      hireDate: json['hireDate']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? '',
    );
  }

  String get roleDisplay {
    switch (roleName.toUpperCase()) {
      case 'RECEPTIONIST':
        return 'Lễ tân';
      case 'SERVICE_STAFF':
        return 'Nhân viên phục vụ';
      case 'HOUSEKEEPER':
        return 'Nhân viên buồng phòng';
      default:
        return roleName;
    }
  }

  String get statusDisplay => isActive ? 'Đang hoạt động' : 'Đã vô hiệu hóa';
}

class CreateAccountPayload {
  const CreateAccountPayload({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.roleName,
    this.salary,
    this.hireDate,
  });

  final String username;
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String roleName;
  final double? salary;
  final String? hireDate;

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
        'roleName': roleName,
        if (salary != null) 'salary': salary,
        if (hireDate != null) 'hireDate': hireDate,
      };
}

class UpdateAccountPayload {
  const UpdateAccountPayload({
    this.email,
    this.fullName,
    this.phone,
    this.roleName,
    this.salary,
    this.password,
  });

  final String? email;
  final String? fullName;
  final String? phone;
  final String? roleName;
  final double? salary;
  final String? password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (email != null) map['email'] = email;
    if (fullName != null) map['fullName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (roleName != null) map['roleName'] = roleName;
    if (salary != null) map['salary'] = salary;
    if (password != null && password!.isNotEmpty) map['password'] = password;
    return map;
  }
}
