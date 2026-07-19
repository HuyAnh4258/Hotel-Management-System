import 'package:get/get.dart';

class ManagerDashboardViewModel extends GetxController {
  // Pillar 1: Inventory & Expense
  final RxInt lowStockItems = 3.obs;
  final RxDouble monthlyExpense = 15450000.0.obs;

  // Pillar 2: Services
  final RxInt activeServices = 12.obs;

  // Pillar 3: Rooms & Types
  final RxInt availableRooms = 45.obs;
  final RxInt totalRooms = 60.obs;

  // Pillar 4: Employees
  final RxInt pendingProfileUpdates = 4.obs;

  // Pillar 5: Maintenance
  final RxInt pendingMaintenanceRequests = 2.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    // Simulate API fetch delay
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
  }
}
