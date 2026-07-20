import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/property_management/viewmodel/property_viewmodel.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(PropertyViewModel());
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý phòng & hạng phòng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: vm.refreshAllData,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Thêm mới',
            onPressed: () {
              if (vm.selectedTab.value == 0) {
                _showRoomDialog(context, vm, null);
              } else {
                _showRoomTypeDialog(context, vm, null);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildKpis(vm, isWide),
          _buildTabBar(vm),
          _buildSearchBar(vm),
          Expanded(
            child: Obx(() {
              if (vm.isLoading.value &&
                  vm.filteredRooms.isEmpty &&
                  vm.filteredRoomTypes.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.accent));
              }

              if (vm.selectedTab.value == 0) {
                return _buildRoomsList(vm, isWide);
              } else {
                return _buildRoomTypesList(vm, isWide);
              }
            }),
          ),
        ],
      ),
    );
  }

  // ─── KPI ROW ──────────────────────────────────────────────────

  Widget _buildKpis(PropertyViewModel vm, bool isWide) {
    return Obx(() {
      if (vm.selectedTab.value == 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(child: _kpiCard('Tổng số phòng', '${vm.totalRooms}', Icons.meeting_room_outlined, AppColors.info)),
              const SizedBox(width: 8),
              Expanded(child: _kpiCard('Sẵn sàng', '${vm.availableRooms}', Icons.check_circle_outline_rounded, AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _kpiCard('Chưa dọn', '${vm.dirtyRooms}', Icons.cleaning_services_outlined, AppColors.danger)),
              if (isWide) ...[
                const SizedBox(width: 8),
                Expanded(child: _kpiCard('Bảo trì', '${vm.maintenanceRooms}', Icons.build_outlined, AppColors.warning)),
              ],
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(child: _kpiCard('Tổng số hạng phòng', '${vm.totalRoomTypes}', Icons.class_outlined, AppColors.primary)),
            ],
          ),
        );
      }
    });
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────

  Widget _buildTabBar(PropertyViewModel vm) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _tabButton('Phòng', 0, vm.selectedTab.value == 0, () => vm.onTabChanged(0))),
              Expanded(child: _tabButton('Hạng phòng', 1, vm.selectedTab.value == 1, () => vm.onTabChanged(1))),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabButton(String label, int index, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────

  Widget _buildSearchBar(PropertyViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: vm.onSearchChanged,
        decoration: InputDecoration(
          hintText: vm.selectedTab.value == 0 ? "Tìm kiếm theo phòng, hạng phòng..." : "Tìm kiếm theo hạng phòng...",
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    vm.onSearchChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ─── ROOMS TAB CONTENT ────────────────────────────────────────

  Widget _buildRoomsList(PropertyViewModel vm, bool isWide) {
    if (vm.filteredRooms.isEmpty) {
      return const Center(child: Text('Không tìm thấy phòng nào', style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.filteredRooms.length,
      itemBuilder: (context, index) {
        final room = vm.filteredRooms[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: room.isActive ? Colors.grey.shade200 : Colors.red.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(room.status).withValues(alpha: 0.12),
              child: Icon(Icons.meeting_room_outlined, color: _getStatusColor(room.status)),
            ),
            title: Row(
              children: [
                Text(
                  'Phòng ${room.roomName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room.status).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    room.statusDisplay,
                    style: TextStyle(color: _getStatusColor(room.status), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Loại: ${room.roomType?.typeName ?? "Chưa thiết lập"} - Tầng: ${room.floorNumber}'),
                if (room.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(room.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => _showRoomDialog(context, vm, room),
                ),
                IconButton(
                  icon: Icon(
                    room.isActive ? Icons.block_rounded : Icons.settings_backup_restore_rounded,
                    color: room.isActive ? AppColors.danger : AppColors.success,
                  ),
                  onPressed: () => vm.toggleRoomActive(room.roomId, !room.isActive),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return AppColors.success;
      case 'DIRTY':
        return AppColors.danger;
      case 'OCCUPIED':
        return AppColors.info;
      case 'CLEANING':
        return Colors.orange;
      case 'MAINTENANCE':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  // ─── ROOM TYPES TAB CONTENT ───────────────────────────────────

  Widget _buildRoomTypesList(PropertyViewModel vm, bool isWide) {
    if (vm.filteredRoomTypes.isEmpty) {
      return const Center(child: Text('Không tìm thấy hạng phòng nào', style: TextStyle(color: AppColors.textSecondary)));
    }

    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.filteredRoomTypes.length,
      itemBuilder: (context, index) {
        final rt = vm.filteredRoomTypes[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: rt.isActive ? Colors.grey.shade200 : Colors.red.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.hotel_outlined, color: AppColors.primary),
            ),
            title: Row(
              children: [
                Text(
                  rt.typeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  '${rt.maxOccupancy} Khách tối đa',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  fmt.format(rt.basePrice),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
                if (rt.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(rt.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => _showRoomTypeDialog(context, vm, rt),
                ),
                IconButton(
                  icon: Icon(
                    rt.isActive ? Icons.block_rounded : Icons.settings_backup_restore_rounded,
                    color: rt.isActive ? AppColors.danger : AppColors.success,
                  ),
                  onPressed: () => vm.toggleRoomTypeActive(rt.roomTypeId, !rt.isActive),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── DIALOGS ──────────────────────────────────────────────────

  void _showRoomDialog(BuildContext context, PropertyViewModel vm, RoomModel? room) {
    final isEdit = room != null;
    final idCtrl = TextEditingController(text: room?.roomId ?? '');
    final nameCtrl = TextEditingController(text: room?.roomName ?? '');
    final floorCtrl = TextEditingController(text: room?.floorNumber.toString() ?? '1');
    final descCtrl = TextEditingController(text: room?.description ?? '');
    String selectedTypeId = room?.roomType?.roomTypeId ?? (vm.roomTypes.isNotEmpty ? vm.roomTypes.first.roomTypeId : '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Cập nhật phòng' : 'Thêm phòng mới', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idCtrl,
                  enabled: !isEdit,
                  decoration: const InputDecoration(labelText: 'Mã phòng (Ví dụ: 101, 102...)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên hiển thị phòng (Ví dụ: Phòng 101)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: floorCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tầng'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTypeId.isNotEmpty ? selectedTypeId : null,
                  decoration: const InputDecoration(labelText: 'Hạng phòng'),
                  items: vm.roomTypes.map((rt) {
                    return DropdownMenuItem(
                      value: rt.roomTypeId,
                      child: Text(rt.typeName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedTypeId = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Mô tả phòng'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final id = idCtrl.text.trim();
                final name = nameCtrl.text.trim();
                final floor = int.tryParse(floorCtrl.text) ?? 1;

                if (id.isEmpty || name.isEmpty || selectedTypeId.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng điền đủ mã phòng, tên phòng và hạng phòng', snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                Navigator.pop(context);
                vm.saveRoom(
                  roomId: id,
                  roomName: name,
                  floorNumber: floor,
                  roomTypeId: selectedTypeId,
                  description: descCtrl.text.trim(),
                  isEdit: isEdit,
                );
              },
              child: const Text('Lưu lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomTypeDialog(BuildContext context, PropertyViewModel vm, RoomTypeModel? rt) {
    final isEdit = rt != null;
    final nameCtrl = TextEditingController(text: rt?.typeName ?? '');
    final priceCtrl = TextEditingController(text: rt?.basePrice.toStringAsFixed(0) ?? '');
    final occupancyCtrl = TextEditingController(text: rt?.maxOccupancy.toString() ?? '2');
    final descCtrl = TextEditingController(text: rt?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Cập nhật hạng phòng' : 'Thêm hạng phòng', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên hạng phòng (Ví dụ: Deluxe, VIP...)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá tiền cơ bản / đêm'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: occupancyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số khách tối đa'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Mô tả hạng phòng'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              final occupancy = int.tryParse(occupancyCtrl.text) ?? 2;

              if (name.isEmpty || price <= 0) {
                Get.snackbar('Lỗi', 'Vui lòng nhập tên hạng phòng và giá tiền hợp lệ', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              Navigator.pop(context);
              vm.saveRoomType(
                id: rt?.roomTypeId ?? '',
                typeName: name,
                basePrice: price,
                maxOccupancy: occupancy,
                description: descCtrl.text.trim(),
                isEdit: isEdit,
              );
            },
            child: const Text('Lưu lại'),
          ),
        ],
      ),
    );
  }
}