import 'package:flutter/material.dart';
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
        return 'Chưa dọn';
      case 'CLEANING':
        return 'Đang dọn';
      case 'AVAILABLE':
        return 'Đã dọn (Sẵn sàng)';
      case 'MAINTENANCE':
        return 'Bảo trì';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Buồng phòng',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
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
        color: Colors.grey.shade50,
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((status) => _RoomListTab(status: status)).toList(),
        ),
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
            backgroundColor: Colors.green),
      );
      _loadRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showActionDialog(RoomModel room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cập nhật trạng thái phòng ${room.roomId}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (room.status == 'DIRTY') ...[
                ListTile(
                  leading: const Icon(Icons.cleaning_services, color: Colors.blue),
                  title: const Text('Bắt đầu dọn dẹp (CLEANING)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(room.roomId, 'CLEANING');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.build, color: Colors.red),
                  title: const Text('Báo cáo hư hỏng (MAINTENANCE)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(room.roomId, 'MAINTENANCE');
                  },
                ),
              ],
              if (room.status == 'CLEANING') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Dọn xong (Sẵn sàng đón khách)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(room.roomId, 'AVAILABLE'); // CLEAN maps to AVAILABLE
                  },
                ),
              ],
              if (room.status == 'AVAILABLE' || room.status == 'MAINTENANCE')
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Phòng hiện không cần dọn hoặc đang bảo trì.'),
                ),
            ],
          ),
        );
      },
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
                    child: Text('Không có phòng nào trong trạng thái này',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),
              ],
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: _getStatusColor(room.status).withValues(alpha: 0.5),
                      width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showActionDialog(room),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getStatusColor(room.status).withValues(alpha: 0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatusIcon(room.status),
                          size: 40,
                          color: _getStatusColor(room.status),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          room.roomId,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          room.roomTypeName,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(room.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room.status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DIRTY':
        return Colors.brown;
      case 'CLEANING':
        return Colors.blue;
      case 'AVAILABLE':
        return Colors.green;
      case 'MAINTENANCE':
        return Colors.red;
      case 'OCCUPIED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'DIRTY':
        return Icons.delete_outline;
      case 'CLEANING':
        return Icons.cleaning_services;
      case 'AVAILABLE':
        return Icons.check_circle_outline;
      case 'MAINTENANCE':
        return Icons.build;
      case 'OCCUPIED':
        return Icons.bed;
      default:
        return Icons.room;
    }
  }
}
