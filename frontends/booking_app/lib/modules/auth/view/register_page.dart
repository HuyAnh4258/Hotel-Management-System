import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodel/auth_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
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
                    'Đăng kí tài khoản để đặt phòng dễ dàng hơn',
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
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 32),
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
              'Đăng kí tài khoản',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vui lòng nhập thông tin để tạo tài khoản',
              style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 28),
            _buildInputField(
              controller: _fullNameCtrl,
              label: 'Họ và tên',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _usernameCtrl,
              label: 'Tên đăng nhập',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _phoneCtrl,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(controller: _passwordCtrl, label: 'Mật khẩu'),
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
                  onPressed: vm.isLoading.value
                      ? null
                      : () => _handleRegister(vm),
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
                      : const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                        ),
                  label: Text(
                    vm.isLoading.value ? 'ĐANG XỬ LÝ...' : 'ĐĂNG KÍ TÀI KHOẢN',
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
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Đã có tài khoản? Đăng nhập',
                  style: TextStyle(
                    color: Color(0xFF0F2557),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập $label' : null,
      decoration: InputDecoration(
        hintText: label,
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

  void _handleRegister(AuthViewModel vm) {
    if (!_formKey.currentState!.validate()) return;

    vm
        .register(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
          email: _emailCtrl.text.trim(),
          fullName: _fullNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        )
        .then((ok) {
          if (ok) {
            Get.snackbar(
              'Thành công',
              'Đăng ký tài khoản thành công. Vui lòng đăng nhập lại.',
            );
            Get.offAllNamed('/login');
          }
        });
  }
}
