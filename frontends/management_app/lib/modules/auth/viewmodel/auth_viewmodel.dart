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
}
