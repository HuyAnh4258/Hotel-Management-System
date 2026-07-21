import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodel/auth_viewmodel.dart';

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

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  Timer? _timer;
  int _secondsLeft = 300;
  int _step = 1;
  String _message = '';
  bool _messageIsError = false;

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message, {required bool isError}) {
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  void _startOtpTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 300;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
      });
    });
  }

  Future<void> _sendOtp(AuthViewModel vm) async {
    if (!_emailFormKey.currentState!.validate()) return;

    final ok = await vm.requestForgotPasswordOtp(_emailCtrl.text.trim());
    if (!mounted) return;

    if (ok) {
      _startOtpTimer();
      setState(() {
        _step = 2;
      });
      _showMessage('Mã OTP đã được gửi đến email của bạn.', isError: false);
    } else {
      _showMessage(vm.errorMessage.value, isError: true);
    }
  }

  Future<void> _verifyOtp(AuthViewModel vm) async {
    if (!_otpFormKey.currentState!.validate()) return;
    if (_secondsLeft <= 0) {
      _showMessage(
        'Mã OTP đã hết hạn, vui lòng gửi lại mã mới.',
        isError: true,
      );
      return;
    }

    final ok = await vm.verifyForgotPasswordOtp(
      _emailCtrl.text.trim(),
      _otpCtrl.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      _timer?.cancel();
      setState(() {
        _step = 3;
      });
      _showMessage('Xác thực OTP thành công.', isError: false);
    } else {
      _showMessage(vm.errorMessage.value, isError: true);
    }
  }

  Future<void> _resetPassword(AuthViewModel vm) async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final ok = await vm.resetPassword(
      email: _emailCtrl.text.trim(),
      otp: _otpCtrl.text.trim(),
      newPassword: _newPasswordCtrl.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công.')),
      );
      Get.offAllNamed('/login');
    } else {
      _showMessage(vm.errorMessage.value, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step > 1) {
              setState(() {
                _step--;
                _message = '';
              });
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepHeader(step: _step),
                      const SizedBox(height: 26),
                      if (_step == 1)
                        _EmailStep(
                          formKey: _emailFormKey,
                          emailCtrl: _emailCtrl,
                        ),
                      if (_step == 2)
                        _OtpStep(
                          formKey: _otpFormKey,
                          otpCtrl: _otpCtrl,
                          email: _emailCtrl.text,
                          secondsLeft: _secondsLeft,
                        ),
                      if (_step == 3)
                        _PasswordStep(
                          formKey: _passwordFormKey,
                          newPasswordCtrl: _newPasswordCtrl,
                          confirmPasswordCtrl: _confirmPasswordCtrl,
                        ),
                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _MessageBox(
                          message: _message,
                          isError: _messageIsError,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: vm.isLoading.value
                                ? null
                                : () {
                                    if (_step == 1) _sendOtp(vm);
                                    if (_step == 2) _verifyOtp(vm);
                                    if (_step == 3) _resetPassword(vm);
                                  },
                            icon: vm.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _step == 3
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                  ),
                            label: Text(_buttonLabel),
                          ),
                        ),
                      ),
                      if (_step == 2) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: vm.isLoading.value || _secondsLeft > 0
                                ? null
                                : () => _sendOtp(vm),
                            child: const Text('Gửi lại OTP'),
                          ),
                        ),
                      ],
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

  String get _buttonLabel {
    if (_step == 1) return 'Gửi mã OTP';
    if (_step == 2) return 'Xác thực OTP';
    return 'Đặt lại mật khẩu';
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Email', 'OTP', 'Mật khẩu mới'];
    return Row(
      children: List.generate(labels.length, (index) {
        final stepNumber = index + 1;
        final active = step >= stepNumber;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: active
                    ? const Color(0xFF0F2557)
                    : const Color(0xFFE5E7EB),
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.formKey, required this.emailCtrl});

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập email tài khoản khách',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chúng tôi sẽ gửi mã OTP 6 số đến email này để xác nhận yêu cầu đặt lại mật khẩu.',
            style: TextStyle(color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Vui lòng nhập email';
              if (!GetUtils.isEmail(email)) return 'Email không đúng định dạng';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.formKey,
    required this.otpCtrl,
    required this.email,
    required this.secondsLeft,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController otpCtrl;
  final String email;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã OTP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã OTP đã được gửi đến $email.',
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 8,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Mã OTP',
              prefixIcon: Icon(Icons.verified_user_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final otp = value?.trim() ?? '';
              if (otp.isEmpty) return 'Vui lòng nhập OTP';
              if (otp.length != 6) return 'OTP phải có đúng 6 số';
              return null;
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              secondsLeft > 0
                  ? 'OTP hết hạn sau $minutes:$seconds'
                  : 'OTP đã hết hạn',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F2557),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    required this.formKey,
    required this.newPasswordCtrl,
    required this.confirmPasswordCtrl,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmPasswordCtrl;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo mật khẩu mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mật khẩu cần có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.',
            style: TextStyle(color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: newPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final password = value?.trim() ?? '';
              if (password.isEmpty) return 'Vui lòng nhập mật khẩu mới';
              final passwordRegExp = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=*!]).{8,}$',
              );
              if (!passwordRegExp.hasMatch(password)) {
                return 'Mật khẩu chưa đủ mạnh';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: confirmPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Xác nhận mật khẩu',
              prefixIcon: Icon(Icons.lock_reset_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final confirmPassword = value?.trim() ?? '';
              if (confirmPassword.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (confirmPassword != newPasswordCtrl.text.trim()) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.redAccent : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
