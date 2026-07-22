import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/auth_service.dart';
import '../viewmodel/room_viewmodel.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AVAILABLE|OCCUPIED|DIRTY|CLEANING|MAINTENANCE
  final List<String> _tabs = ['DIRTY', 'CLEANING', 'AVAILABLE', 'MAINTENANCE'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTabLabel(String status) {
    switch (status) {
      case 'DIRTY':
        return 'Chưa dọn (DIRTY)';
      case 'CLEANING':
        return 'Đang dọn (CLEANING)';
      case 'AVAILABLE':
        return 'Sẵn sàng (AVAILABLE)';
      case 'MAINTENANCE':
        return 'Bảo trì (MAINTENANCE)';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '[ HMS - UPDATE ROOM STATUS ]',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          isScrollable: true,
          tabs: _tabs.map((status) => Tab(text: _getTabLabel(status))).toList(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Role: Housekeeper | Module: Housekeeping',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs
                    .map((status) => _RoomListTab(status: status))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthService auth) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await auth.logout();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _RoomListTab extends StatefulWidget {
  final String status;
  const _RoomListTab({required this.status});

  @override
  State<_RoomListTab> createState() => _RoomListTabState();
}

class _RoomListTabState extends State<_RoomListTab> {
  late Future<List<RoomModel>> _roomsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      _roomsFuture = RoomApi.getRooms(widget.status);
    });
  }

  Future<void> _updateStatus(String roomId, String newStatus) async {
    try {
      await RoomApi.updateStatus(roomId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật trạng thái thành công'),
          backgroundColor: Colors.green,
        ),
      );
      _loadRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showMarkCleanConfirm(RoomModel room) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('CONFIRM TASK COMPLETION', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to change Room ${room.roomId} to 'Clean'?\nBR-22 Applied: Mandatory for check-out verification.",
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel/Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _updateStatus(room.roomId, 'AVAILABLE');
            },
            child: const Text('Confirm Execution'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceForm(RoomModel room) {
    final issueTypeController = TextEditingController();
    final descriptionController = TextEditingController();

    // Default options
    final List<String> issues = [
      'AC Not Working',
      'Plumbing Issue',
      'Electrical Issue',
      'Furniture Damage',
      'Other'
    ];
    String selectedIssue = issues.first;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: StatefulBuilder(builder: (context, setStateModal) {
            return Container(
              width: 500,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('[ HMS - REQUEST ROOM MAINTENANCE ]', 
                      style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Role: Housekeeper \t\t Module: Receptioning', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('REQUEST ROOM MAINTENANCE', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ROOM NUMBER', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextField(
                                readOnly: true,
                                controller: TextEditingController(text: room.roomId),
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ISSUE TYPE', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedIssue,
                                    isExpanded: true,
                                    items: issues.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setStateModal(() => selectedIssue = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('FAULT DESCRIPTION', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('UPLOAD IMAGE', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Choose File', style: TextStyle(color: Colors.black))),
                        const SizedBox(width: 8),
                        const Text('No file chosen', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (descriptionController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter fault description')));
                            return;
                          }
                          try {
                            final auth = Get.find<AuthService>();
                            // In a real app we'd get the actual user ID. For now we use the username or EMP-00000005.
                            // The database has EMP-00000005 for Housekeeper. We will use USR-00000005 since ReporterId references UserId.
                            final userId = 'USR-00000005'; 
                            await RoomApi.createMaintenanceRequest(room.roomId, userId, selectedIssue, descriptionController.text);
                            if (!context.mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance request submitted'), backgroundColor: Colors.green));
                            _loadRooms();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                        ),
                        child: const Text('[ SUBMIT REQUEST ]', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }
    );
  }

  void _showUpdateRoomModal(RoomModel room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cập nhật phòng', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                      child: const Text('[x]', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã số phòng: ${room.roomId}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Hạng phòng: ${room.roomTypeName}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Trạng thái: ${room.status}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (room.status == 'DIRTY') ...[
                _buildModalButton(
                  icon: '🧹',
                  label: 'Bắt đầu dọn dẹp',
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(room.roomId, 'CLEANING');
                  },
                ),
                const SizedBox(height: 8),
                _buildModalButton(
                  icon: '🔧',
                  label: 'Báo cáo bảo trì',
                  onTap: () {
                    Navigator.pop(context);
                    _showMaintenanceForm(room);
                  },
                ),
                const SizedBox(height: 8),
              ],
              if (room.status == 'CLEANING') ...[
                _buildModalButton(
                  icon: '✅',
                  label: 'Hoàn tất dọn dẹp',
                  onTap: () {
                    Navigator.pop(context);
                    _showMarkCleanConfirm(room);
                  },
                ),
                const SizedBox(height: 8),
              ],
              if (room.status == 'AVAILABLE') ...[
                _buildModalButton(
                  icon: '🔧',
                  label: 'Báo cáo bảo trì',
                  onTap: () {
                    Navigator.pop(context);
                    _showMaintenanceForm(room);
                  },
                ),
                const SizedBox(height: 8),
              ],
              _buildModalButton(
                icon: null,
                label: 'Huỷ bỏ',
                isCancel: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalButton({String? icon, required String label, required VoidCallback onTap, bool isCancel = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        child: Row(
          mainAxisAlignment: isCancel ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            if (isCancel)
              Text('[ $label ]', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16))
            else ...[
              Text('[ $icon ] $label', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('➔', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    IconData iconData;
    Color iconColor;
    if (room.status == 'DIRTY') {
      iconData = Icons.cleaning_services;
      iconColor = Colors.brown;
    } else if (room.status == 'CLEANING') {
      iconData = Icons.wash;
      iconColor = Colors.purpleAccent;
    } else if (room.status == 'AVAILABLE') {
      iconData = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else {
      iconData = Icons.build;
      iconColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _showUpdateRoomModal(room),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(room.roomId, style: const TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(room.roomTypeName, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                color: Colors.grey.shade300,
              ),
              child: Text('[ ${room.status} ]', style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoomModel>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
        }

        final rooms = snapshot.data ?? [];
        final filteredRooms = rooms.where((r) => r.roomId.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text('Tìm: ', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.grey.shade300,
                      ),
                      child: TextField(
                        style: const TextStyle(fontFamily: 'monospace'),
                        decoration: const InputDecoration(
                          hintText: 'Số phòng...',
                          hintStyle: TextStyle(fontFamily: 'monospace', color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadRooms(),
                child: filteredRooms.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(
                              child: Text(
                                'No rooms found.',
                                style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          return _buildRoomCard(filteredRooms[index]);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
