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
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hotel,
                        size: 52,
                        color: Color(0xFF1E88E5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập hoặc email',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Vui lòng nhập tên đăng nhập hoặc email'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Vui lòng nhập mật khẩu'
                            : null,
                        onFieldSubmitted: (_) => _handleLogin(vm),
                      ),
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
                        child: Obx(
                          () => ElevatedButton.icon(
                            onPressed: vm.isLoading.value
                                ? null
                                : () => _handleLogin(vm),
                            icon: vm.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              vm.isLoading.value
                                  ? 'ĐANG XỬ LÝ...'
                                  : 'ĐĂNG NHẬP',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Get.to(() => const RegisterPage()),
                        child: const Text('Chưa có tài khoản? Đăng ký ngay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
