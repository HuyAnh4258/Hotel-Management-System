import 'package:get/get.dart';
import 'token_storage.dart';

class AuthService extends GetxService {
  final TokenStorage _tokenStorage;

  final RxBool isLoggedIn = false.obs;
  final RxString userId = ''.obs;
  final RxString username = ''.obs;
  final RxString fullName = ''.obs;
  final RxList<String> roles = <String>[].obs;

  AuthService(this._tokenStorage);

  Future<void> init() async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      isLoggedIn.value = true;
      userId.value = (await _tokenStorage.getUserId()) ?? '';
      username.value = (await _tokenStorage.getUsername()) ?? '';
      fullName.value = (await _tokenStorage.getFullName()) ?? '';
      final r = await _tokenStorage.getRoles();
      if (r != null) roles.value = r.split(',');
    }
  }

  bool hasAnyRole(List<String> allowed) {
    return roles.any((r) => allowed.contains(r));
  }

  Future<void> logout() async {
    await _tokenStorage.clearAll();
    isLoggedIn.value = false;
    userId.value = '';
    username.value = '';
    fullName.value = '';
    roles.clear();
  }
}
