import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/core/widgets/app_widgets.dart';
import 'package:management_app/modules/auth/viewmodel/auth_viewmodel.dart';
import 'dart:async';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  String _errorMsg = '';
  String _successMsg = '';
  Timer? _timer;
  int _start = 300; // 300 giây = 5 phút
  bool _isTimerRunning = false;

  void _startTimer() {
    setState(() {
      _start = 300;
      _isTimerRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isTimerRunning = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    setState(() {
      _errorMsg = msg;
      _successMsg = '';
    });
  }

  void _showSuccess(String msg) {
    setState(() {
      _successMsg = msg;
      _errorMsg = '';
    });
  }

  Future<void> _sendOtp(AuthViewModel vm) async {
    print(
      "--- [Forgot Password] Initiating OTP send for: ${_emailCtrl.text} ---",
    );
    if (!_formKey1.currentState!.validate()) {
      print("--- [Forgot Password] Form validation failed ---");
      return;
    }
    _showError('');
    print("--- [Forgot Password] Calling requestForgotPasswordOtp API ---");

    try {
      final err = await vm.requestForgotPasswordOtp(_emailCtrl.text.trim());
      print("--- [Forgot Password] API response error: $err ---");
      if (err == null) {
        _showSuccess('Mã OTP đã được gửi đến email của bạn.');
        _startTimer();
        setState(() {
          _step = 2;
        });
      } else {
        _showError(err);
      }
    } catch (e, stack) {
      print("--- [Forgot Password] Exception caught in UI: $e ---");
      print(stack);
      _showError(e.toString());
    }
  }

  Future<void> _verifyOtp(AuthViewModel vm) async {
    if (!_formKey2.currentState!.validate()) return;

    if (_start == 0) {
      _showError('Mã OTP đã hết hạn, vui lòng gửi lại mã mới!');
      setState(() {
        _isTimerRunning = false;
      });
      return;
    }

    _showError('');

    final err = await vm.verifyForgotPasswordOtp(
      _emailCtrl.text.trim(),
      _otpCtrl.text.trim(),
    );
    if (err == null) {
      _timer?.cancel();
      _showSuccess('Xác thực OTP thành công. Vui lòng nhập mật khẩu mới.');
      setState(() {
        _step = 3;
      });
    } else {
      if (err.contains('hết hạn')) {
        setState(() {
          _isTimerRunning = false;
        });
        _showError('Mã OTP đã hết hạn, vui lòng gửi lại mã mới!');
      } else {
        _showError(err);
      }
    }
  }

  Future<void> _resetPassword(AuthViewModel vm) async {
    if (!_formKey3.currentState!.validate()) return;
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }
    _showError('');

    final err = await vm.resetPassword(
      _emailCtrl.text.trim(),
      _otpCtrl.text.trim(),
      _newPasswordCtrl.text,
    );
    if (err == null) {
      Get.snackbar(
        'Thành công',
        'Mật khẩu của bạn đã được cập nhật thành công.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      Get.offAllNamed('/login');
    } else {
      _showError(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_step > 1) {
              setState(() {
                _step--;
                _errorMsg = '';
                _successMsg = '';
              });
            } else {
              Get.back();
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Khôi phục mật khẩu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stepDot(1, 'Email'),
                      _stepLine(),
                      _stepDot(2, 'Nhập OTP'),
                      _stepLine(),
                      _stepDot(3, 'Mật khẩu mới'),
                    ],
                  ),
                  const SizedBox(height: 36),

                  if (_step == 1) _buildEmailStep(vm),
                  if (_step == 2) _buildOtpStep(vm),
                  if (_step == 3) _buildNewPasswordStep(vm),

                  const SizedBox(height: 20),

                  // Messages
                  if (_errorMsg.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMsg,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_successMsg.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _successMsg,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int stepNum, String label) {
    final isActive = _step >= stepNum;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
      color: AppColors.border,
    );
  }

  Widget _buildEmailStep(AuthViewModel vm) {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập email của bạn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chúng tôi sẽ gửi một mã OTP gồm 6 chữ số đến địa chỉ email này để xác nhận tài khoản của bạn.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ Email',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
              hintText: 'example@gmail.com',
            ),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Vui lòng nhập Email';
              if (!GetUtils.isEmail(v.trim()))
                return 'Email không đúng định dạng';
              return null;
            },
          ),
          const SizedBox(height: 28),
          Obx(
            () => PrimaryButton(
              label: 'GỬI MÃ OTP',
              icon: Icons.send,
              isLoading: vm.isLoading.value,
              onPressed: vm.isLoading.value ? null : () => _sendOtp(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AuthViewModel vm) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã xác thực OTP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                  text: 'Vui lòng nhập mã OTP 6 số đã được gửi đến ',
                ),
                TextSpan(
                  text: _emailCtrl.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Mã xác thực OTP',
              prefixIcon: Icon(Icons.security, size: 20),
            ),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Vui lòng nhập OTP';
              if (v.trim().length != 6) return 'Mã OTP phải có đúng 6 chữ số';
              return null;
            },
          ),
          const SizedBox(height: 28),
          Obx(
            () => PrimaryButton(
              label: 'XÁC THỰC',
              icon: Icons.verified_user_outlined,
              isLoading: vm.isLoading.value,
              onPressed: vm.isLoading.value ? null : () => _verifyOtp(vm),
            ),
          ),
          const SizedBox(height: 16),
          if (_isTimerRunning)
            Center(
              child: Text(
                'Mã OTP hết hạn sau: ${(_start ~/ 60).toString().padLeft(2, '0')}:${(_start % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: (vm.isLoading.value || _isTimerRunning) ? null : () => _sendOtp(vm),
              child: Text(
                'Gửi lại mã OTP',
                style: TextStyle(
                  color: _isTimerRunning ? AppColors.textHint : AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordStep(AuthViewModel vm) {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thiết lập mật khẩu mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập mật khẩu mới của bạn bên dưới để hoàn tất việc khôi phục quyền truy cập tài khoản.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _newPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: Icon(Icons.lock_outline, size: 20),
            ),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Vui lòng nhập mật khẩu mới';
              final passwordRegExp = RegExp(
                  r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=*!]).{8,}$");
              if (!passwordRegExp.hasMatch(v.trim())) {
                return 'Mật khẩu phải từ 8 ký tự, gồm chữ hoa, thường, số và ký tự đặc biệt';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Xác nhận mật khẩu mới',
              prefixIcon: Icon(Icons.lock_reset, size: 20),
            ),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (v.trim() != _newPasswordCtrl.text.trim()) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          Obx(
            () => PrimaryButton(
              label: 'ĐẶT LẠI MẬT KHẨU',
              icon: Icons.check,
              isLoading: vm.isLoading.value,
              onPressed: vm.isLoading.value ? null : () => _resetPassword(vm),
            ),
          ),
        ],
      ),
    );
  }
}
