import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/profile/viewmodel/profile_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(ProfileViewModel());
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (vm.isLoading.value && vm.fullNameController.text.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        return isMobile
            ? _MobileLayout(vm: vm)
            : _DesktopLayout(vm: vm);
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MOBILE LAYOUT — Single column, scroll view
// ═══════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AvatarSection(vm: vm, size: 90),
          const SizedBox(height: 28),
          _FormSection(vm: vm, isMobile: true),
          const SizedBox(height: 32),
          _SaveButton(vm: vm, fullWidth: true),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DESKTOP LAYOUT — Two columns
// ═══════════════════════════════════════════════════════════

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left panel: Avatar + info ──────────────────
                  SizedBox(
                    width: 260,
                    child: _DesktopAvatarPanel(vm: vm),
                  ),
                  const SizedBox(width: 28),
                  // ── Right panel: Form ──────────────────────────
                  Expanded(
                    child: _DesktopFormPanel(vm: vm),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopAvatarPanel extends StatelessWidget {
  const _DesktopAvatarPanel({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _AvatarSection(vm: vm, size: 96),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          // Read-only info rows
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Tên đăng nhập',
            value: vm.username,
          ),
          const SizedBox(height: 12),
          Obx(() => _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Vai trò',
            value: vm.roleLabel,
          )),
        ],
      ),
    );
  }
}

class _DesktopFormPanel extends StatelessWidget {
  const _DesktopFormPanel({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Thông tin cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cập nhật thông tin hồ sơ của bạn. Thay đổi sẽ được lưu ngay lập tức.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          _FormSection(vm: vm, isMobile: false),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: _SaveButton(vm: vm, fullWidth: false),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════

// ── Avatar Section ──────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.vm, required this.size});
  final ProfileViewModel vm;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final initial = vm.avatarInitial;
          return Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              // Accent dot badge
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.check,
                    size: size * 0.12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        Obx(() => Text(
          vm.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        )),
        const SizedBox(height: 4),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            vm.roleLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 0.3,
            ),
          ),
        )),
      ],
    );
  }
}

// ── Form Section ────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  const _FormSection({required this.vm, required this.isMobile});
  final ProfileViewModel vm;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Validation error banner
        Obx(() {
          if (vm.errorMessage.value.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.errorMessage.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        _FieldLabel('Họ và tên *'),
        const SizedBox(height: 8),
        TextFormField(
          controller: vm.fullNameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: _inputDecoration(
            hint: 'Nhập họ và tên đầy đủ',
            icon: Icons.person_outline_rounded,
          ),
          onChanged: (_) => vm.errorMessage.value = '',
        ),
        const SizedBox(height: 20),

        _FieldLabel('Số điện thoại'),
        const SizedBox(height: 8),
        TextFormField(
          controller: vm.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: _inputDecoration(
            hint: 'VD: 0901 234 567',
            icon: Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 20),

        _FieldLabel('Email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: vm.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: _inputDecoration(
            hint: 'VD: example@email.com',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 20),

        _FieldLabel('Tên đăng nhập (Không thể thay đổi)'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                vm.username.isNotEmpty ? vm.username : '---',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ── Field Label ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Info Row (Desktop Panel) ─────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '---',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Save Button ─────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.vm, required this.fullWidth});
  final ProfileViewModel vm;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = vm.isLoading.value;
      return SizedBox(
        width: fullWidth ? double.infinity : 200,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : vm.saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: loading ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

