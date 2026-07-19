import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'register_page.dart';
import 'viewmodel/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/booking_bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.42)),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withOpacity(0.08)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 30,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildBrandPanel(
                                    height: 280,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                  ),
                                  _buildFormPanel(
                                    vm,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(28),
                                    ),
                                  ),
                                ],
                              )
                            : IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildBrandPanel(),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: _buildFormPanel(vm),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPanel({double? height, BorderRadius? borderRadius}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1E4D), Color(0xFF1C3573)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 2,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hotel Management System',
                    style: TextStyle(
                      color: Color(0xFFD7DEEE),
                      fontSize: 18,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Đặt phòng nhanh chóng, tiện lợi và an toàn',
                    style: TextStyle(
                      color: Color(0xFF9FB0D3),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(AuthViewModel vm, {BorderRadius? borderRadius}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 46),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Đăng nhập để tiếp tục đặt phòng',
              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 36),
            _buildInputField(
              controller: _usernameCtrl,
              label: 'Tên đăng nhập',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 18),
            _buildPasswordField(),
            const SizedBox(height: 12),
            Obx(
              () => vm.errorMessage.isNotEmpty
                  ? Text(
                      vm.errorMessage.value,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: vm.isLoading.value ? null : () => _handleLogin(vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2557),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: vm.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login_rounded, color: Colors.white),
                  label: Text(
                    vm.isLoading.value ? 'ĐANG XỬ LÝ...' : 'ĐĂNG NHẬP',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () => Get.to(() => const RegisterPage()),
                    child: const Text(
                      'Chưa có tài khoản? Đăng kí tài khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F2557),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tài khoản đăng ký sẽ dùng để đặt phòng Booking',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Vui lòng nhập $label' : null,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF8F8FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0F2557), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: true,
      validator: (v) =>
          v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
      onFieldSubmitted: (_) => _handleLogin(Get.find<AuthViewModel>()),
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF8F8FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0F2557), width: 1.4),
        ),
      ),
    );
  }

  void _handleLogin(AuthViewModel vm) {
    if (!_formKey.currentState!.validate()) return;

    vm.login(_usernameCtrl.text.trim(), _passwordCtrl.text).then((ok) {
      if (!ok) return;

      if (vm.isReceptionist) {
        Get.offAllNamed('/receptionist');
      } else if (vm.isGuest) {
        Get.offAllNamed('/dashboard');
      } else {
        vm.errorMessage.value = 'Tài khoản không có quyền truy cập hệ thống';
      }
    });
  }
}
