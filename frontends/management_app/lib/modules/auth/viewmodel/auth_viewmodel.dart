import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_model.dart';
import 'package:hms_shared/auth/auth_provider.dart';
import 'package:hms_shared/auth/auth_service.dart';
import 'package:hms_shared/auth/token_storage.dart';
import 'package:hms_shared/network/dio_client.dart';

class AuthViewModel extends GetxController {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;
  late final AuthProvider _authProvider;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  AuthViewModel(this._dioClient, this._tokenStorage) {
    _authProvider = AuthProvider(_dioClient.dio);
  }

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authProvider.login(
        LoginRequest(username: username, password: password),
      );

      await _tokenStorage.saveSession(
        accessToken: response.accessToken,
        userId: response.userId,
        username: response.username,
        roles: response.roles.join(','),
        fullName: response.fullName,
      );

      // Update AuthService in-memory state
      final auth = Get.find<AuthService>();
      auth.isLoggedIn.value = true;
      auth.userId.value = response.userId;
      auth.username.value = response.username;
      auth.fullName.value = response.fullName ?? '';
      auth.roles.value = response.roles;

      return true;
    } catch (e) {
      errorMessage.value = 'Sai tên đăng nhập hoặc mật khẩu';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> requestForgotPasswordOtp(String email) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password/request',
        data: {'email': email},
      );
      return null;
    } catch (e) {
      print("--- [AuthViewModel] requestForgotPasswordOtp failed. Exception: $e ---");
      return _extractError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> verifyForgotPasswordOtp(String email, String otp) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password/verify',
        data: {'email': email, 'otp': otp},
      );
      return null;
    } catch (e) {
      print("--- [AuthViewModel] verifyForgotPasswordOtp failed. Exception: $e ---");
      return _extractError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> resetPassword(String email, String otp, String newPassword) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password/reset',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return null;
    } catch (e) {
      print("--- [AuthViewModel] resetPassword failed. Exception: $e ---");
      if (e is DioException) {
        print("--- [AuthViewModel] resetPassword response status: ${e.response?.statusCode} ---");
        print("--- [AuthViewModel] resetPassword response data: ${e.response?.data} ---");
        print("--- [AuthViewModel] resetPassword response data type: ${e.response?.data?.runtimeType} ---");
      }
      return _extractError(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _extractError(dynamic e) {
    try {
      if (e is DioException && e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        print("--- [AuthViewModel] _extractError data: $data ---");
        print("--- [AuthViewModel] _extractError data type: ${data.runtimeType} ---");
        if (data is Map && data.containsKey('message')) {
          final msg = data['message'] as String;
          if (msg.isNotEmpty) return msg;
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }
    } catch (_) {}
    return 'Đã có lỗi xảy ra khi kết nối tới hệ thống. Vui lòng kiểm tra lại.';
  }
}
