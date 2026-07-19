import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hms_shared/auth/auth_service.dart';
import '../viewmodel/booking_viewmodel.dart';


class CancelRequestsPage extends StatefulWidget {
  const CancelRequestsPage({super.key});

  @override
  State<CancelRequestsPage> createState() => _CancelRequestsPageState();
}

class _CancelRequestsPageState extends State<CancelRequestsPage> {
  late Future<List<BookingSummary>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = BookingApi.getBookings();
  }

  Future<void> _reload() async {
    setState(() {
      _bookingsFuture = BookingApi.getBookings();
    });
  }

  Future<void> _approveCancel(BookingSummary booking) async {
    await BookingApi.approveCancelBooking(booking.bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã duyệt yêu cầu hủy, đơn hàng đã hủy')),
    );
    await _reload();
  }

  Future<void> _rejectCancel(BookingSummary booking) async {
    await BookingApi.rejectCancelBooking(booking.bookingId);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã từ chối yêu cầu hủy')));
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Duyệt hủy booking'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              const Color(0xFFF6F8FC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<BookingSummary>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                  children: [_ErrorCard(onRetry: _reload)],
                );
              }

              final bookings = (snapshot.data ?? [])
                  .where((b) => b.isWaitingCancelApproval)
                  .toList();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _CancelRequestsHeader(totalRequests: bookings.length),
                  const SizedBox(height: 18),
                  if (bookings.isEmpty)
                    const Text('Không có yêu cầu hủy nào')
                  else
                    ...bookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CancelRequestCard(
                          booking: booking,
                          onApprove: () => _approveCancel(booking),
                          onReject: () => _rejectCancel(booking),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CancelRequestsHeader extends StatelessWidget {
  const _CancelRequestsHeader({required this.totalRequests});

  final int totalRequests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách yêu cầu hủy',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Lễ tân duyệt đồng ý để chuyển trạng thái đơn hàng sang đã hủy hoặc từ chối yêu cầu.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _Badge(label: '$totalRequests yêu cầu', color: Colors.orange),
        ],
      ),
    );
  }
}

class _CancelRequestCard extends StatelessWidget {
  const _CancelRequestCard({
    required this.booking,
    required this.onApprove,
    required this.onReject,
  });

  final BookingSummary booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.guestName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('Mã booking: ${booking.bookingId}'),
          Text('SĐT: ${booking.phone}'),
          Text(
            booking.rooms.isEmpty
                ? 'Phòng: Chưa có thông tin'
                : 'Phòng: ${booking.rooms.join(", ")}',
          ),
          const SizedBox(height: 8),
          _Badge(label: 'Đợi lễ tân duyệt hủy', color: Colors.orange),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Đồng ý'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Từ chối'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoomStatusPage extends StatefulWidget {
  const RoomStatusPage({super.key});

  @override
  State<RoomStatusPage> createState() => _RoomStatusPageState();
}

class _RoomStatusPageState extends State<RoomStatusPage> {
  late Future<List<RoomModel>> _roomsFuture;
  String _selectedRoomStatus = 'AVAILABLE';

  @override
  void initState() {
    super.initState();
    _roomsFuture = BookingApi.getRoomsByStatus(status: _selectedRoomStatus);
  }

  Future<void> _reload() async {
    setState(() {
      _roomsFuture = BookingApi.getRoomsByStatus(status: _selectedRoomStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Trạng thái phòng'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              const Color(0xFFF6F8FC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            children: [
              _RoomStatusHeader(
                selectedRoomStatus: _selectedRoomStatus,
                onStatusChanged: (status) {
                  setState(() {
                    _selectedRoomStatus = status;
                    _roomsFuture = BookingApi.getRoomsByStatus(
                      status: _selectedRoomStatus,
                    );
                  });
                },
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<RoomModel>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorCard(onRetry: _reload);
                  }

                  final rooms = snapshot.data ?? [];
                  if (rooms.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'Không có phòng phù hợp với trạng thái đã chọn',
                      ),
                    );
                  }

                  return Column(
                    children: rooms
                        .map(
                          (room) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RoomStatusCard(room: room),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckInOutPage extends StatefulWidget {
  const CheckInOutPage({super.key});

  @override
  State<CheckInOutPage> createState() => _CheckInOutPageState();
}

class _CheckInOutPageState extends State<CheckInOutPage> {
  late Future<List<BookingSummary>> _bookingsFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bookingsFuture = BookingApi.getBookings(
      date: _formatDate(_selectedDate),
      userId: Get.find<AuthService>().userId.value,
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _reload() async {
    setState(() {
      _bookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
        userId: Get.find<AuthService>().userId.value,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _bookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
        userId: Get.find<AuthService>().userId.value,
      );
    });
  }

  Future<void> _changeStatus(String bookingId, String status) async {
    await BookingApi.updateBookingStatus(bookingId, status);
    if (!mounted) return;
    setState(() {
      _bookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
        userId: Get.find<AuthService>().userId.value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Check-in / Check-out'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              const Color(0xFFF6F8FC),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            children: [
              _CheckInOutHeader(
                selectedDate: _selectedDate,
                onPickDate: _pickDate,
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<BookingSummary>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorCard(onRetry: _reload);
                  }

                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Không có booking nào theo ngày đã chọn'),
                    );
                  }

                  return Column(
                    children: bookings
                        .map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookingCard(
                              booking: booking,
                              onCheckIn:
                                  booking.canCheckIn(_formatDate(_selectedDate))
                                  ? () => _changeStatus(
                                      booking.bookingId,
                                      'CHECKED_IN',
                                    )
                                  : null,
                              onCheckOut:
                                  booking.canCheckOut(
                                    _formatDate(_selectedDate),
                                  )
                                  ? () => _changeStatus(
                                      booking.bookingId,
                                      'CHECKED_OUT',
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInOutHeader extends StatelessWidget {
  const _CheckInOutHeader({
    required this.selectedDate,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in / Check-out',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Chỉ dùng để xử lý nhận phòng và trả phòng.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.date_range_rounded),
            label: Text(
              'Ngày: ${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(label: 'PENDING', color: schemeColor(context).tertiary),
              const SizedBox(width: 8),
              _Badge(label: 'CHECKED_IN', color: schemeColor(context).primary),
              const SizedBox(width: 8),
              _Badge(label: 'CHECKED_OUT', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  ColorScheme schemeColor(BuildContext context) =>
      Theme.of(context).colorScheme;
}

class _RoomStatusHeader extends StatelessWidget {
  const _RoomStatusHeader({
    required this.selectedRoomStatus,
    required this.onStatusChanged,
  });

  final String selectedRoomStatus;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái phòng',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Lễ tân xem danh sách phòng theo trạng thái.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusFilterChip(
                label: 'AVAILABLE',
                selected: selectedRoomStatus == 'AVAILABLE',
                onTap: () => onStatusChanged('AVAILABLE'),
              ),
              _StatusFilterChip(
                label: 'BOOKED',
                selected: selectedRoomStatus == 'BOOKED',
                onTap: () => onStatusChanged('BOOKED'),
              ),
              _StatusFilterChip(
                label: 'MAINTENANCE',
                selected: selectedRoomStatus == 'MAINTENANCE',
                onTap: () => onStatusChanged('MAINTENANCE'),
              ),
              _StatusFilterChip(
                label: 'ALL',
                selected: selectedRoomStatus == 'ALL',
                onTap: () => onStatusChanged('ALL'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Badge(label: 'AVAILABLE', color: scheme.primary),
        ],
      ),
    );
  }
}

class _RoomStatusCard extends StatelessWidget {
  const _RoomStatusCard({required this.room});

  final RoomModel room;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.bed_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Tầng ${room.floor}'),
                Text('Trạng thái: ${room.status}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: scheme.primary.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? scheme.primary : Colors.grey.shade700,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final BookingSummary booking;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCheckOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.guestName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('SĐT: ${booking.phone}'),
          Text(
            booking.rooms.isEmpty
                ? 'Phòng: Chưa có thông tin'
                : 'Phòng: ${booking.rooms.join(", ")}',
          ),
          Text('Checkin: ${booking.expectedCheckin}'),
          Text('Checkout: ${booking.expectedCheckout}'),
          Text('Status: ${booking.status}'),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onCheckIn != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onCheckIn,
                    child: const Text('Checkin'),
                  ),
                ),
              if (onCheckIn != null && onCheckOut != null)
                const SizedBox(width: 8),
              if (onCheckOut != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onCheckOut,
                    child: const Text('CheckOut'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          const Text('Không tải được dữ liệu'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Tải lại')),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
