import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/core/widgets/app_widgets.dart';
import 'package:management_app/modules/auth/viewmodel/auth_viewmodel.dart';
import 'package:hms_shared/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _ctrl;
  late final Animation<double> _cardSlide;
  late final Animation<double> _brandFade;
  late final Animation<double> _goldLineWidth;
  late final Animation<double> _field1Slide;
  late final Animation<double> _field2Slide;
  late final Animation<double> _buttonFade;

  static const _bgUrl =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&q=80';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _brandFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _goldLineWidth = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    );
    _field1Slide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
    );
    _field2Slide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
    );
    _buttonFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 720;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _bgUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(color: AppColors.primary);
            },
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                    Color(0xFF162447),
                  ],
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.40)),
          ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => isWide ? _buildWide(vm) : _buildNarrow(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWide(AuthViewModel vm) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - _cardSlide.value)),
        child: Opacity(
          opacity: _cardSlide.value,
          child: Container(
            margin: const EdgeInsets.all(24),
            width: 860,
            height: 520,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFF1A2D5A)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -60,
                          right: -60,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          left: -50,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.03),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 56, bottom: 56),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeTransition(
                                opacity: _brandFade,
                                child: const Text(
                                  'FPT Golden',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedBuilder(
                                animation: _goldLineWidth,
                                builder: (_, __) => Container(
                                  height: 3,
                                  width: 40 * _goldLineWidth.value,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FadeTransition(
                                opacity: _brandFade,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hotel Management System',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white60,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Quản lý thông minh, vận hành tinh gọn',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white30,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 44,
                      vertical: 24,
                    ),
                    child: _buildForm(vm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrow(AuthViewModel vm) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _brandFade,
                    child: Column(
                      children: [
                        const Text(
                          'FPT Golden',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedBuilder(
                          animation: _goldLineWidth,
                          builder: (_, __) => Container(
                            height: 2,
                            width: 28 * _goldLineWidth.value,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Hotel Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Opacity(
                    opacity: _cardSlide.value,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - _cardSlide.value)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: _buildForm(vm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(AuthViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Đăng nhập để tiếp tục',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.2, 0),
              end: Offset.zero,
            ).animate(_field1Slide),
            child: FadeTransition(
              opacity: _field1Slide,
              child: TextFormField(
                controller: _usernameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.2, 0),
              end: Offset.zero,
            ).animate(_field2Slide),
            child: FadeTransition(
              opacity: _field2Slide,
              child: TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                ),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                onFieldSubmitted: (_) => _handleLogin(vm),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed('/forgot-password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Obx(
            () => vm.errorMessage.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 15,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vm.errorMessage.value,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 10),
          ),

          const SizedBox(height: 8),
          FadeTransition(
            opacity: _buttonFade,
            child: PrimaryButton(
              label: 'ĐĂNG NHẬP',
              icon: Icons.login,
              isLoading: vm.isLoading.value,
              onPressed: vm.isLoading.value ? null : () => _handleLogin(vm),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _buttonFade,
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                'Chưa có tài khoản? Hãy thông báo với quản lý',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(AuthViewModel vm) {
    if (!_formKey.currentState!.validate()) return;
    vm.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim()).then((ok) {
      if (ok) {
        final auth = Get.find<AuthService>();
        if (auth.hasAnyRole(['RECEPTIONIST'])) {
          Get.offAllNamed('/receptionist');
        } else {
          Get.offAllNamed('/dashboard');
        }
      }
    });
  }
}
