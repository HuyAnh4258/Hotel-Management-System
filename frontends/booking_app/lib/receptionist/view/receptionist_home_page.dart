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
      appBar: AppBar(
        title: const Text('Lễ tân'),
        actions: [
          IconButton(
            onPressed: authVm.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF6C48E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lễ tân',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Xin chào, $username',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Phần dành riêng cho lễ tân. Chọn chức năng bên dưới để chuyển trang thực hiện nghiệp vụ.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RoomStatusPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.meeting_room_rounded),
                      label: const Text('Xem trạng thái phòng'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheckInOutPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.badge_rounded),
                      label: const Text('Check-in / Check-out'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CancelRequestsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel_presentation_rounded),
                      label: const Text('Duyệt hủy booking'),
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
}
