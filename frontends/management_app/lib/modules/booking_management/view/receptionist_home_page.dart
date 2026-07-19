import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hms_shared/auth/auth_service.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/dashboard/viewmodel/manager_dashboard_viewmodel.dart';
import 'package:management_app/modules/dashboard/widgets/summary_card_widget.dart';
import 'package:management_app/modules/dashboard/widgets/action_card_widget.dart';
import 'receptionist_subpages.dart';

class ReceptionistHomePage extends StatelessWidget {
  const ReceptionistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final vm = Get.put(ManagerDashboardViewModel());
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

              // Overview Section (Summary Cards)
              Obx(() {
                if (vm.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
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
                    'Nghiệp vụ lễ tân',
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
                sliver: _buildActionGrid(context, isWide, width),
              ),
            ],
          ),
        ),
      ),
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

  // ─── Hero Banner ──────────────────────────────────────────────
  Widget _buildHeroBanner(AuthService auth) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/'
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: const Text(
                  'LỄ TÂN',
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
            'Hệ thống quản lý check-in, check-out và tiếp nhận yêu cầu hủy phòng từ khách hàng.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ─── Summary Section ──────────────────────────────────────────
  Widget _buildSummaryGrid(
    ManagerDashboardViewModel vm,
    bool isWide,
    double width,
  ) {
    int cols = 2;
    double ratio = 2.1;

    if (width > 900) {
      cols = 2;
      ratio = 2.4;
    } else if (width > 600) {
      cols = 2;
      ratio = 1.95;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: ratio,
      ),
      delegate: SliverChildListDelegate([
        // Pillar 1: Phòng & Hạng phòng
        SummaryCardWidget(
          title: 'Trạng thái phòng',
          metrics: ['Trống: ${vm.availableRooms.value}/${vm.totalRooms.value}'],
          icon: Icons.meeting_room_outlined,
          themeColor: AppColors.success,
        ),
        // Pillar 2: Bảo trì
        SummaryCardWidget(
          title: 'Yêu cầu bảo trì',
          metrics: ['Yêu cầu: ${vm.pendingMaintenanceRequests.value}'],
          icon: Icons.build_outlined,
          themeColor: const Color(0xFF0891B2),
        ),
      ]),
    );
  }

  // ─── Action Section ──────────────────────────────────────────
  Widget _buildActionGrid(BuildContext context, bool isWide, double width) {
    int cols = 2;
    double ratio = 2.0;

    if (width > 900) {
      cols = 3;
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
      delegate: SliverChildListDelegate([
        ActionCardWidget(
          label: 'Trạng thái phòng',
          description: 'Xem phòng AVAILABLE, BOOKED, MAINTENANCE',
          icon: Icons.bed,
          themeColor: Colors.orange,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RoomStatusPage()));
          },
        ),
        ActionCardWidget(
          label: 'Check-in / Check-out',
          description: 'Xử lý nhận phòng và trả phòng theo ngày',
          icon: Icons.badge,
          themeColor: Colors.deepOrange,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CheckInOutPage()));
          },
        ),
        ActionCardWidget(
          label: 'Duyệt hủy booking',
          description: 'Xem và xử lý các yêu cầu hủy từ khách',
          icon: Icons.cancel_presentation,
          themeColor: Colors.redAccent,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CancelRequestsPage()),
            );
          },
        ),
        ActionCardWidget(
          label: 'View Order Status',
          description: 'Xem trang thai order dich vu',
          icon: Icons.list_alt_rounded,
          themeColor: Colors.blueAccent,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ServiceOrderStatusPage(canUpdate: false),
              ),
            );
          },
        ),
        ActionCardWidget(
          label: 'Update Order Status',
          description: 'Cap nhat tien do order dich vu',
          icon: Icons.manage_history_rounded,
          themeColor: Colors.teal,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ServiceOrderStatusPage(canUpdate: true),
              ),
            );
          },
        ),
        ActionCardWidget(
          label: 'Export Invoice',
          description: 'Xuat hoa don order dich vu',
          icon: Icons.receipt_long_rounded,
          themeColor: Colors.indigo,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportInvoicePage()),
            );
          },
        ),
        ActionCardWidget(
          label: 'View Order Requests',
          description: 'Xem cac order dang cho xu ly',
          icon: Icons.pending_actions_rounded,
          themeColor: Colors.amber.shade700,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrderRequestsPage()),
            );
          },
        ),
        ActionCardWidget(
          label: 'Process Order',
          description: 'Nhan va hoan tat order dich vu',
          icon: Icons.playlist_add_check_circle_rounded,
          themeColor: Colors.green,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProcessOrderPage()));
          },
        ),
      ]),
    );
  }
}
