import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_service.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/dashboard/view/manager_dashboard_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Animation<double>? _fade;
  Animation<double> get _fadeOrOne =>
      _fade ?? const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Obx(() {
<<<<<<< Updated upstream
=======
      if (auth.hasAnyRole(['RECEPTIONIST'])) {
        // Redirect receptionist to their home immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/receptionist');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
>>>>>>> Stashed changes
      if (auth.hasAnyRole(['OWNER'])) {
        final isWide = MediaQuery.of(context).size.width > 800;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(auth),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
              child: _buildOwnerView(auth),
            ),
          ),
        );
      }
      return const ManagerDashboardScreen();
    });
  }

  // ─── Owner View ────────────────────────────────
  Widget _buildOwnerView(AuthService auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(auth),
        const SizedBox(height: 24),
        _sectionTitle('Chức năng của Chủ sở hữu'),
        const SizedBox(height: 12),
        _ownerCard(
          'Đặt & Điều chỉnh giá',
          'Quản lý giá bán vật tư và dịch vụ',
          Icons.sell,
          AppColors.accent,
          true,
          () => Get.toNamed('/pricing'),
        ),
        const SizedBox(height: 12),
        _ownerCard(
          'Quản lý Voucher',
          'Tạo và quản lý mã giảm giá, khuyến mãi',
          Icons.card_giftcard_outlined,
          const Color(0xFF7C3AED),
          true,
          () => Get.toNamed('/vouchers'),
        ),
        const SizedBox(height: 12),
        _ownerCard(
          'Báo cáo & Phân tích',
          'Doanh thu, lợi nhuận, tỉ lệ lấp đầy',
          Icons.analytics_outlined,
          AppColors.info,
          false,
          null,
        ),
        const SizedBox(height: 12),
        _ownerCard(
          'Audit hệ thống',
          'Nhật ký hoạt động và thay đổi',
          Icons.history,
          const Color(0xFF4B5563),
          false,
          null,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Manager View ──────────────────────────────
  Widget _buildManagerView(AuthService auth, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(auth),
        const SizedBox(height: 20),
        _buildKpiRow(auth, isWide),
        const SizedBox(height: 28),
        _sectionTitle('Quản lý vận hành'),
        const SizedBox(height: 8),
        _buildModuleGrid(auth, isWide),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── AppBar ────────────────────────────────────
  PreferredSizeWidget _buildAppBar(AuthService auth) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'FG',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FPT Golden',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                'Management',
                style: TextStyle(fontSize: 10, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Obx(
          () => Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      (auth.fullName.value.isNotEmpty
                              ? auth.fullName.value
                              : auth.username.value.isNotEmpty
                              ? auth.username.value
                              : 'U')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.fullName.value.isNotEmpty
                          ? auth.fullName.value
                          : auth.username.value.isNotEmpty
                          ? auth.username.value
                          : 'User',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _roleLabel(auth.roles.firstOrNull ?? ''),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => _confirmLogout(auth),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 15),
                SizedBox(width: 6),
                Text('ĐĂNG XUẤT'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Header ────────────────────────────────────
  Widget _buildHeader(AuthService auth) {
    return FadeTransition(
      opacity: _fadeOrOne,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bảng điều khiển',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          _greeting(auth),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Obx(
                    () => Text(
                      _roleLabel(auth.roles.firstOrNull ?? ''),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _greetingDetail(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI ───────────────────────────────────────
  Widget _buildKpiRow(AuthService auth, bool isWide) {
    final vm = Get.find<InventoryViewModel>();
    return FadeTransition(
      opacity: _fadeOrOne,
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _kpiCard(
                'Tổng vật tư',
                '${vm.totalItems}',
                Icons.inventory_2_outlined,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _kpiCard(
                'Sắp hết',
                '${vm.lowStockCount}',
                Icons.warning_amber_rounded,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _kpiCard(
                'Đã hết',
                '${vm.outOfStockCount}',
                Icons.inventory_2,
                AppColors.danger,
              ),
            ),
            if (isWide) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _kpiCard(
                  'Tổng giá trị',
                  _fmtVnd(vm.totalValue),
                  Icons.monetization_on_outlined,
                  AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Owner Cards ───────────────────────────────
  Widget _ownerCard(
    String title,
    String desc,
    IconData icon,
    Color color,
    bool isReady,
    VoidCallback? onTap,
  ) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: InkWell(
        onTap: isReady ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isReady
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isReady
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isReady
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.textHint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isReady ? 'Sẵn sàng' : 'Sắp ra mắt',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isReady ? AppColors.success : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isReady ? Icons.chevron_right : Icons.lock_outline,
                size: 18,
                color: isReady ? color : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Module Grid ───────────────────────────────
  Widget _buildModuleGrid(AuthService auth, bool isWide) {
    final modules = _buildModules(auth);
    return FadeTransition(
      opacity: _fadeOrOne,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = isWide ? 4 : 2;
          final cardW = (constraints.maxWidth - (cols - 1) * 12) / cols;
          final cardH = 150.0;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: cardW / cardH,
            ),
            itemCount: modules.length,
            itemBuilder: (_, i) => _buildModuleTile(modules[i]),
          );
        },
      ),
    );
  }

  Widget _buildModuleTile(_Module m) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: m.color.withValues(alpha: 0.15),
      child: InkWell(
        onTap: m.isReady ? () => Get.toNamed(m.route) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(
                color: m.isReady ? m.color : AppColors.border,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m.icon, size: 20, color: m.color),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: m.isReady
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.textHint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      m.isReady ? 'Sẵn sàng' : 'Sắp ra mắt',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: m.isReady
                            ? AppColors.success
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                m.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: m.isReady
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                m.desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: m.isReady
                      ? AppColors.textSecondary
                      : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    m.isReady ? Icons.arrow_forward : Icons.lock_outline,
                    size: 14,
                    color: m.isReady ? m.color : AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    m.isReady ? 'Truy cập' : 'Chưa mở',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: m.isReady ? m.color : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Module> _buildModules(AuthService auth) {
    return [
      _Module(
        'Quản lý phòng',
        'Theo dõi trạng thái & giá phòng',
        Icons.meeting_room_outlined,
        '/property',
        AppColors.info,
        true,
      ),
      _Module(
        'Đặt phòng',
        'Quản lý booking & khách hàng',
        Icons.book_online_outlined,
        '/booking',
        AppColors.success,
        false,
      ),
      _Module(
        'Kho & Chi phí',
        'Vật tư, điều chỉnh, báo cáo',
        Icons.inventory_2_outlined,
        '/inventory',
        AppColors.accent,
        true,
      ),
      _Module(
        'Nhân viên',
        'Hồ sơ & phân công ca',
        Icons.people_outline,
        '/employees',
        AppColors.warning,
        false,
      ),
      _Module(
        'Báo cáo',
        'Doanh thu & vận hành',
        Icons.analytics_outlined,
        '/reports',
        const Color(0xFF4B5563),
        false,
      ),
      _Module(
        'Dịch vụ',
        'Quản lý dịch vụ khách sạn',
        Icons.room_service_outlined,
        '/services',
        AppColors.info,
        false,
      ),
      _Module(
        'Bảo trì',
        'Yêu cầu sửa chữa phòng',
        Icons.build_outlined,
        '/maintenance',
        const Color(0xFF0891B2),
        false,
      ),
    ];
  }

  // ─── Section Title ─────────────────────────────
  Widget _sectionTitle(String title) {
    return FadeTransition(
      opacity: _fadeOrOne,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ─── Logout ────────────────────────────────────
  void _confirmLogout(AuthService auth) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Xác nhận đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bạn có chắc chắn muốn đăng xuất?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Huỷ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await auth.logout();
                          Get.offAllNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ─── Helpers ───────────────────────────────────
  String _greeting(AuthService auth) {
    final h = DateTime.now().hour;
    final t = h < 12
        ? 'buổi sáng'
        : h < 18
        ? 'buổi chiều'
        : 'buổi tối';
    final n = auth.fullName.value.isNotEmpty
        ? auth.fullName.value
        : auth.username.value;
    return 'Chào $n, chúc bạn một $t tốt lành!';
  }

  String _greetingDetail() {
    final h = DateTime.now().hour;
    if (h < 12) {
      return 'Buổi sáng là thời điểm lý tưởng để kiểm tra tình trạng phòng và lên kế hoạch.';
    }
    if (h < 18) {
      return 'Tiếp tục giám sát hoạt động và đảm bảo chất lượng dịch vụ trong suốt buổi chiều.';
    }
    return 'Tổng kết hoạt động trong ngày và chuẩn bị cho ngày mai.';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'OWNER':
        return 'Chủ sở hữu';
      case 'MANAGER':
        return 'Quản lý';
      case 'RECEPTIONIST':
        return 'Lễ tân';
      case 'SERVICE_STAFF':
        return 'Nhân viên DV';
      case 'HOUSEKEEPER':
        return 'Dọn phòng';
      default:
        return role;
    }
  }

  String _fmtVnd(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)} tỷ';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)} triệu';
    final parts = value.toStringAsFixed(0).split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write('.');
      buf.write(parts[0][i]);
    }
    return buf.toString();
  }
}

class _Module {
  final String label, desc;
  final IconData icon;
  final String route;
  final Color color;
  final bool isReady;
  _Module(
    this.label,
    this.desc,
    this.icon,
    this.route,
    this.color,
    this.isReady,
  );
}
