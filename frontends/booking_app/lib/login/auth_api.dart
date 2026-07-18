import 'package:dio/dio.dart';

class AuthApi {
  AuthApi._();

  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {'username': username, 'password': password},
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    final response = await _dio.post(
      '/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
        'fullName': fullName,
        'phone': phone,
      },
    );
    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

class AuthResponse {
  AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.roles,
    required this.roleIds,
    required this.fullName,
  });

  final String accessToken;
  final String userId;
  final String username;
  final List<String> roles;
  final List<String> roleIds;
  final String fullName;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      roleIds: (json['roleIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      fullName: json['fullName']?.toString() ?? '',
    );
  }
}
