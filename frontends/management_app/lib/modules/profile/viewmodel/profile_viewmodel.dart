import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_service.dart';
import 'package:management_app/modules/employee_management/viewmodel/account_viewmodel.dart';

class ProfileViewModel extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  // ─── Form controllers ───────────────────────────
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // ─── Reactive state ─────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSaved = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Read-only info (from auth) ─────────────────
  String get username => _auth.username.value;
  String get roleName => _auth.roles.firstOrNull ?? '';
  String get displayName =>
      _auth.fullName.value.isNotEmpty ? _auth.fullName.value : username;

  String get roleLabel {
    switch (roleName.toUpperCase()) {
      case 'OWNER':
        return 'Chủ khách sạn';
      case 'MANAGER':
        return 'Quản lý';
      case 'RECEPTIONIST':
        return 'Lễ tân';
      case 'HOUSEKEEPER':
        return 'Nhân viên buồng phòng';
      case 'SERVICE_STAFF':
        return 'Nhân viên phục vụ';
      default:
        return roleName;
    }
  }

  String get avatarInitial {
    final name = _auth.fullName.value.isNotEmpty
        ? _auth.fullName.value
        : _auth.username.value;
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> _loadProfileData() async {
    final userId = _auth.userId.value;
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final account = await AccountApi.getAccountById(userId);
      fullNameController.text = account.fullName;
      phoneController.text = account.phone;
      emailController.text = account.email;
    } catch (e) {
      // Fallback local if API fails
      fullNameController.text = _auth.fullName.value;
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegExp = RegExp(r"^(?:[+0]9)?[0-9]{9,11}$");
    return phoneRegExp.hasMatch(phone);
  }

  Future<void> saveProfile() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty) {
      errorMessage.value = 'Họ và tên không được để trống';
      return;
    }

    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      errorMessage.value = 'Số điện thoại không hợp lệ (yêu cầu từ 9 đến 11 chữ số)';
      return;
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      errorMessage.value = 'Địa chỉ Email không đúng định dạng';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isSaved.value = false;

    try {
      final userId = _auth.userId.value;
      if (userId.isNotEmpty) {
        await AccountApi.updateAccount(
          userId,
          UpdateAccountPayload(
            fullName: fullName.isNotEmpty ? fullName : null,
            phone: phone.isNotEmpty ? phone : null,
            email: email.isNotEmpty ? email : null,
          ),
        );
      }
      _auth.fullName.value = fullName;
      isSaved.value = true;
      Get.snackbar(
        'Thành công',
        'Thông tin hồ sơ đã được cập nhật',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } catch (e) {
      errorMessage.value = 'Lỗi cập nhật: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
