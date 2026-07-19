import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/viewmodel/auth_viewmodel.dart';
import 'cancel_requests_page.dart';
import 'check_in_out_page.dart';
import 'room_status_page.dart';

class ReceptionistHomePage extends StatelessWidget {
  const ReceptionistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Get.find<AuthViewModel>();
    final username = authVm.currentUser.value?.username ?? 'lễ tân';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lễ tân'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: authVm.logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF4E6),
              Color(0xFFFFE1C2),
              Color(0xFFFFF8F1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 900;

                        return isMobile
                            ? Column(
                                children: [
                                  _buildHeroPanel(
                                    context,
                                    username: username,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(30),
                                    ),
                                  ),
                                  _buildActionsPanel(
                                    context,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(30),
                                    ),
                                  ),
                                ],
                              )
                            : IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildHeroPanel(
                                        context,
                                        username: username,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: _buildActionsPanel(context),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(
    BuildContext context, {
    required String username,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A00), Color(0xFFE66A00)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: _GlowCircle(size: 220, opacity: 0.12),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: _GlowCircle(size: 180, opacity: 0.08),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Booking Reception',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khu vực lễ tân',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Xin chào, $username',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Quản lý check-in, check-out, trạng thái phòng và duyệt yêu cầu hủy trong giao diện đồng bộ với Booking.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(
                    child: _MiniStat(
                      label: 'Check-in',
                      value: 'Nhanh',
                      icon: Icons.login_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Phòng',
                      value: 'Realtime',
                      icon: Icons.meeting_room_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'Hủy booking',
                      value: 'Duyệt',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsPanel(
    BuildContext context, {
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chức năng lễ tân',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn nghiệp vụ bên dưới để thao tác.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 28),
          _ActionCard(
            title: 'Trạng thái phòng',
            subtitle: 'Xem phòng AVAILABLE, BOOKED, MAINTENANCE hoặc ALL.',
            icon: Icons.bed_rounded,
            color: const Color(0xFFFF8A00),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RoomStatusPage()));
            },
          ),
          const SizedBox(height: 14),
          _ActionCard(
            title: 'Check-in / Check-out',
            subtitle: 'Xử lý nhận phòng và trả phòng theo ngày.',
            icon: Icons.badge_rounded,
            color: const Color(0xFFE66A00),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CheckInOutPage()));
            },
          ),
          const SizedBox(height: 14),
          _ActionCard(
            title: 'Duyệt hủy booking',
            subtitle: 'Xem và xử lý các yêu cầu hủy từ khách.',
            icon: Icons.cancel_presentation_rounded,
            color: const Color(0xFFFF9F43),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CancelRequestsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD8B0)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(opacity), width: 2),
      ),
    );
  }
}
