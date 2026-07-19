import 'package:dio/dio.dart';
import 'package:hms_shared/auth/auth_model.dart';
import 'package:hms_shared/constants/api_constants.dart';

class AuthProvider {
  final Dio _dio;

  AuthProvider(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
