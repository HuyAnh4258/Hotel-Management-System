import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodel/order_viewmodel.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  final List<String> _tabs = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];

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
      case 'PENDING':
        return 'Chờ xử lý';
      case 'IN_PROGRESS':
        return 'Đang thực hiện';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Order Dịch Vụ',
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
          children: _tabs.map((status) => _OrderListTab(status: status)).toList(),
        ),
      ),
    );
  }
}

class _OrderListTab extends StatefulWidget {
  final String status;
  const _OrderListTab({required this.status});

  @override
  State<_OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends State<_OrderListTab> {
  late Future<List<OrderModel>> _ordersFuture;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = OrderApi.getOrders(widget.status);
    });
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await OrderApi.updateStatus(orderId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cập nhật trạng thái thành công'),
            backgroundColor: Colors.green),
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showActionDialog(OrderModel order) {
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
              Text('Cập nhật trạng thái',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (order.status == 'PENDING') ...[
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.blue),
                  title: const Text('Bắt đầu thực hiện (IN PROGRESS)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(order.orderId, 'IN_PROGRESS');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Hủy order (CANCEL)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(order.orderId, 'CANCELLED');
                  },
                ),
              ],
              if (order.status == 'IN_PROGRESS') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Hoàn thành & Tiêu hao (COMPLETED)'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(order.orderId, 'COMPLETED');
                  },
                ),
              ],
              if (order.status == 'COMPLETED' || order.status == 'CANCELLED')
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Không thể thay đổi trạng thái của order này nữa.'),
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
      onRefresh: () async => _loadOrders(),
      child: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text('Không có order nào trong trạng thái này',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showActionDialog(order),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderId,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Khách hàng: ${order.guestName}',
                                style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payments, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Tổng tiền: ${currencyFormat.format(order.totalAmount)}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Thời gian: ${_formatDate(order.orderedAt)}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade700)),
                          ],
                        ),
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
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
