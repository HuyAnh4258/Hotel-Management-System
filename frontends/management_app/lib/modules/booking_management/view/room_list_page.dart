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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadRooms(),
      child: FutureBuilder<List<RoomModel>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text(
                      'No rooms in this state.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTIVE TASKS LIST (IN PROGRESS)', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('CURRENTLY ${widget.status}', style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                    const SizedBox(height: 16),
                    DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade300),
                      border: TableBorder.all(color: Colors.grey.shade400, width: 1),
                      columns: const [
                        DataColumn(label: Text('ROOM NUMBER', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ROOM TYPE', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('START TIME', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ASSIGNED TO', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ACTION', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                      ],
                      rows: rooms.map((room) {
                        return DataRow(
                          cells: [
                            DataCell(Text(room.roomId, style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text(room.roomTypeName, style: const TextStyle(fontFamily: 'monospace'))),
                            DataCell(const Text('10:30 AM', style: TextStyle(fontFamily: 'monospace'))), // Mocked as per image
                            DataCell(const Text('You', style: TextStyle(fontFamily: 'monospace'))), // Mocked as per image
                            DataCell(
                              Row(
                                children: [
                                  if (room.status == 'DIRTY') ...[
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(room.roomId, 'CLEANING'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                      child: const Text('[ Start Cleaning ]', style: TextStyle(fontFamily: 'monospace')),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _showMaintenanceForm(room),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                      child: const Text('[ Request Maint. ]', style: TextStyle(fontFamily: 'monospace')),
                                    ),
                                  ],
                                  if (room.status == 'CLEANING')
                                    ElevatedButton(
                                      onPressed: () => _showMarkCleanConfirm(room),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                      child: const Text('[ Mark as Clean ]', style: TextStyle(fontFamily: 'monospace')),
                                    ),
                                  if (room.status == 'AVAILABLE' || room.status == 'MAINTENANCE')
                                    const Text('No Action', style: TextStyle(fontFamily: 'monospace', color: Colors.grey)),
                                ],
                              )
                            ),
                          ]
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
