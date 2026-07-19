import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_service.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/dashboard/viewmodel/manager_dashboard_viewmodel.dart';
import 'package:management_app/modules/dashboard/widgets/summary_card_widget.dart';
import 'package:management_app/modules/dashboard/widgets/action_card_widget.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/operation_analysis/viewmodel/service_viewmodel.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(ManagerDashboardViewModel());
    final auth = Get.find<AuthService>();
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 750;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(auth),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: vm.refreshDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Hero Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: _buildHeroBanner(auth),
                ),
              ),

              // Overview Section Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Tổng quan hoạt động',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Overview Section (Summary Cards in Grid stretching screen)
              Obx(() {
                if (vm.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildSummaryGrid(vm, isWide, width),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Operational Section Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quản lý vận hành',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Operational Management Section (Action Cards)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: _buildActionGrid(vm, isWide, width),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero Banner ──────────────────────────────────────────────

  Widget _buildHeroBanner(AuthService auth) {
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
    final name = auth.fullName.value.isNotEmpty
        ? auth.fullName.value
        : auth.username.value;
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: const Text(
                  'QUẢN LÝ',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$greeting, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hôm nay có vẻ là một ngày bận rộn. Hãy cùng kiểm tra các chỉ số vận hành bên dưới.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary Section ──────────────────────────────────────────

  Widget _buildSummaryGrid(ManagerDashboardViewModel vm, bool isWide, double width) {
    int cols = 2;
    double ratio = 1.35; // Lower ratio means taller card to prevent text overflow

    if (width > 900) {
      cols = 5;
      ratio = 1.6;
    } else if (width > 600) {
      cols = 3;
      ratio = 1.45;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: ratio,
      ),
      delegate: SliverChildListDelegate(_getSummaryCards(vm)),
    );
  }

  List<Widget> _getSummaryCards(ManagerDashboardViewModel vm) {
    final inventoryVm = Get.find<InventoryViewModel>();
    final serviceVm = Get.find<ServiceViewModel>();

    final activeServices = serviceVm.items.where((s) => s.isActive).toList();
    final singleCount = activeServices.where((s) => !s.isComposite).length;
    final compositeCount = activeServices.where((s) => s.isComposite).length;
    final pricedCount = activeServices.where((s) => s.isPriced).length;

    return [
      // Pillar 1: Inventory & Expense
      SummaryCardWidget(
        title: 'Vật tư & Chi phí',
        metrics: [
          'Tổng mục: ${inventoryVm.totalItems}',
          'Sắp hết: ${inventoryVm.lowStockCount}',
          'Đã hết: ${inventoryVm.outOfStockCount}',
          'Tổng trị giá: ${_fmtShortVnd(inventoryVm.totalValue)}',
        ],
        icon: Icons.warehouse_outlined,
        themeColor: AppColors.accent,
      ),
      // Pillar 2: Services
      SummaryCardWidget(
        title: 'Dịch vụ hiện có',
        metrics: [
          'Hoạt động: ${activeServices.length}',
          'Đơn lẻ: $singleCount',
          'Phức hợp: $compositeCount',
          'Đã đặt giá: $pricedCount',
        ],
        icon: Icons.room_service_outlined,
        themeColor: AppColors.info,
      ),
      // Pillar 3: Phòng & Hạng phòng
      SummaryCardWidget(
        title: 'Trạng thái phòng',
        metrics: ['Trống: ${vm.availableRooms.value}/${vm.totalRooms.value}'],
        icon: Icons.meeting_room_outlined,
        themeColor: AppColors.success,
      ),
      // Pillar 4: Nhân sự
      SummaryCardWidget(
        title: 'Yêu cầu cập nhật',
        metrics: ['Đang chờ: ${vm.pendingProfileUpdates.value}'],
        icon: Icons.people_outline,
        themeColor: AppColors.warning,
        badgeCount: vm.pendingProfileUpdates.value,
      ),
      // Pillar 5: Bảo trì
      SummaryCardWidget(
        title: 'Yêu cầu bảo trì',
        metrics: ['Yêu cầu: ${vm.pendingMaintenanceRequests.value}'],
        icon: Icons.build_outlined,
        themeColor: const Color(0xFF0891B2),
      ),
    ];
  }

  // ─── Operational Section ──────────────────────────────────────

  Widget _buildActionGrid(ManagerDashboardViewModel vm, bool isWide, double width) {
    int cols = 2;
    double ratio = 2.0;

    if (width > 900) {
      cols = 5;
      ratio = 1.6;
    } else if (width > 600) {
      cols = 3;
      ratio = 1.9;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: ratio,
      ),
      delegate: SliverChildListDelegate(_getActionCards(vm)),
    );
  }

  List<Widget> _getActionCards(ManagerDashboardViewModel vm) {
    return [
      // Pillar 1: Inventory & Expense
      ActionCardWidget(
        label: 'Quản lý vật tư',
        description: 'Nhập kho & Cập nhật vật tư',
        icon: Icons.warehouse,
        themeColor: AppColors.accent,
        onTap: () => Get.toNamed('/inventory'),
      ),
      // Pillar 2: Services
      ActionCardWidget(
        label: 'Quản lý dịch vụ',
        description: 'Cài đặt & Thiết lập dịch vụ',
        icon: Icons.room_service,
        themeColor: AppColors.info,
        onTap: () => Get.toNamed('/services'),
      ),
      // Pillar 3: Rooms & Types
      ActionCardWidget(
        label: 'Quản lý phòng',
        description: 'Trạng thái phòng & Hạng phòng',
        icon: Icons.meeting_room,
        themeColor: AppColors.success,
        onTap: () => Get.toNamed('/property'),
      ),
      // Pillar 4: Employees
      ActionCardWidget(
        label: 'Quản lý nhân viên',
        description: 'Hồ sơ & Phân công công việc',
        icon: Icons.people,
        themeColor: AppColors.warning,
        onTap: () => Get.toNamed('/employees'),
      ),
      // Pillar 5: Maintenance
      ActionCardWidget(
        label: 'Phê duyệt bảo trì',
        description: 'Ghi nhận chi phí bảo trì phòng',
        icon: Icons.build,
        themeColor: const Color(0xFF0891B2),
        onTap: () => Get.toNamed('/maintenance'),
      ),
    ];
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _fmtShortVnd(double value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)} triệu';
    return '${value.toStringAsFixed(0)}đ';
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
              color: Colors.white.withOpacity(0.12),
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
                    color: AppColors.accent.withOpacity(0.12),
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
}
