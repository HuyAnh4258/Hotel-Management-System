import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../auth_api.dart';

class AuthViewModel extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentUser = Rxn<AuthResponse>();

  bool get isLoggedIn => currentUser.value != null;

  static const String guestRoleId = 'ROL-00000006';
  static const String receptionistRoleId = 'ROL-00000003';

  bool get isGuest => _hasRole('GUEST', roleId: guestRoleId);

  bool get isReceptionist =>
      _hasRole('RECEPTIONIST', roleId: receptionistRoleId);

  void logout() {
    currentUser.value = null;
    errorMessage.value = '';
    Get.offAllNamed('/login');
  }

  bool _hasRole(String role, {String? roleId}) {
    return currentUser.value?.roles.any((userRole) {
          final normalizedRole = userRole.toUpperCase().replaceAll('ROLE_', '');
          return normalizedRole == role ||
              normalizedRole == roleId?.toUpperCase();
        }) ??
        false;
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await AuthApi.login(
        username: username,
        password: password,
      );
      currentUser.value = response;
      return true;
    } catch (e) {
      errorMessage.value = _normalizeError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await AuthApi.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      currentUser.value = null;
      return true;
    } catch (e) {
      errorMessage.value = _normalizeError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestForgotPasswordOtp(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthApi.requestForgotPasswordOtp(email: email);
      return true;
    } catch (e) {
      errorMessage.value = _normalizeError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthApi.verifyForgotPasswordOtp(email: email, otp: otp);
      return true;
    } catch (e) {
      errorMessage.value = _normalizeError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await AuthApi.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      errorMessage.value = _normalizeError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      return error.response?.statusMessage ?? 'Đăng nhập thất bại';
    }
    return 'Đăng nhập thất bại';
  }
}
