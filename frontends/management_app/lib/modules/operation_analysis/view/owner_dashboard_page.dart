import 'package:flutter/material.dart';
import '../viewmodel/report_viewmodel.dart';
import 'package:intl/intl.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển chủ khách sạn',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Doanh thu'),
            Tab(icon: Icon(Icons.money_off), text: 'Chi phí'),
            Tab(icon: Icon(Icons.meeting_room), text: 'Công suất'),
            Tab(icon: Icon(Icons.feedback), text: 'Đánh giá'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRevenueReport(),
            _buildCostReport(),
            _buildOccupancyReport(),
            _buildFeedbackReport(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // REVENUE
  // ==========================================
  Widget _buildRevenueReport() {
    return FutureBuilder<RevenueReport>(
      future: ReportApi.getRevenueReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi tải dữ liệu doanh thu'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(
              title: 'Tổng doanh thu',
              value: currencyFormat.format(data.totalRevenue),
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text('Doanh thu 6 tháng gần nhất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            ...data.monthlyRevenue.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: Colors.blue),
                    title: Text(m.month,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      currencyFormat.format(m.amount),
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  // ==========================================
  // COST
  // ==========================================
  Widget _buildCostReport() {
    return FutureBuilder<CostReport>(
      future: ReportApi.getCostReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi tải dữ liệu chi phí'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(
              title: 'Tổng chi phí',
              value: currencyFormat.format(data.totalCost),
              icon: Icons.money_off,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text('Chi phí 6 tháng gần nhất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            ...data.monthlyCost.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: Colors.red),
                    title: Text(m.month,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      currencyFormat.format(m.amount),
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  // ==========================================
  // OCCUPANCY
  // ==========================================
  Widget _buildOccupancyReport() {
    return FutureBuilder<OccupancyReport>(
      future: ReportApi.getOccupancyReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi tải dữ liệu phòng'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(
              title: 'Tỷ lệ lấp đầy (Occupancy Rate)',
              value: '${data.occupancyRate}%',
              icon: Icons.pie_chart,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard('Tổng số phòng',
                      data.totalRooms.toString(), Colors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                      'Phòng trống', data.availableRooms.toString(), Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard('Đang sử dụng',
                      data.occupiedRooms.toString(), Colors.orange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMiniCard(
                      'Bảo trì', data.maintenanceRooms.toString(), Colors.red),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // FEEDBACK
  // ==========================================
  Widget _buildFeedbackReport() {
    return FutureBuilder<FeedbackReport>(
      future: ReportApi.getFeedbackReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi tải dữ liệu đánh giá'));
        }

        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Điểm trung bình',
                    value: '${data.averageRating} / 5',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Tổng đánh giá',
                    value: data.totalReviews.toString(),
                    icon: Icons.reviews,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Đánh giá mới nhất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            ...data.recentFeedbacks.map((f) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f.guestName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < f.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(f.date),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          f.comment.isEmpty
                              ? '(Không có nhận xét)'
                              : f.comment,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  Widget _buildSummaryCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 28,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
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
