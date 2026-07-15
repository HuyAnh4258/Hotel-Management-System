import 'package:flutter/material.dart';

import '../viewmodel/booking_viewmodel.dart';
import '../widgets/room_type_card.dart';
import 'booking_pages.dart';

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  late Future<HomepageData> _homepageFuture;
  late Future<List<BookingSummary>> _receptionBookingsFuture;
  bool _receptionMode = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _homepageFuture = BookingApi.getHomepage();
    _receptionBookingsFuture = BookingApi.getBookings(
      date: _formatDate(_selectedDate),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _reload() async {
    setState(() {
      _homepageFuture = BookingApi.getHomepage();
      _receptionBookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
      );
    });
  }

  Future<void> _pickReceptionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _receptionBookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
      );
    });
  }

  Future<void> _changeStatus(String bookingId, String status) async {
    await BookingApi.updateBookingStatus(bookingId, status);
    if (!mounted) return;

    setState(() {
      _homepageFuture = BookingApi.getHomepage();
      _receptionBookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_receptionMode ? 'Lễ tân - Bookings' : 'Hotel Booking'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _receptionMode = !_receptionMode;
              });
            },
            icon: Icon(
              _receptionMode ? Icons.hotel_rounded : Icons.badge_rounded,
            ),
            label: Text(_receptionMode ? 'Khách' : 'Lễ tân'),
          ),
        ],
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
          child: _receptionMode
              ? _buildReceptionView(context)
              : _buildGuestView(context),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return FutureBuilder<HomepageData>(
      future: _homepageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 24),
            children: [_ErrorCard(onRetry: _reload)],
          );
        }

        final data = snapshot.data ?? HomepageData.empty();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _GuestHeader(data: data),
            const SizedBox(height: 18),
            Text(
              'Loại phòng',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (data.roomTypes.isEmpty)
              const Text('Chưa có loại phòng nào')
            else
              ...data.roomTypes.map(
                (roomType) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RoomTypeCard(
                    title: roomType.name,
                    subtitle:
                        '${roomType.description}\nGiá từ ${roomType.basePrice.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RoomTypeDetailPage(
                            roomType: roomType,
                            availableRooms: data.rooms
                                .where(
                                  (room) =>
                                      room.roomTypeId == roomType.roomTypeId,
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReceptionView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _ReceptionHeader(
          selectedDate: _selectedDate,
          onPickDate: _pickReceptionDate,
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<BookingSummary>>(
          future: _receptionBookingsFuture,
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
                            ? () =>
                                  _changeStatus(booking.bookingId, 'CHECKED_IN')
                            : null,
                        onCheckOut:
                            booking.canCheckOut(_formatDate(_selectedDate))
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
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({required this.data});

  final HomepageData data;

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
            'Chào mừng đến với hệ thống đặt phòng',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Khám phá các loại phòng và đặt chỗ nhanh chóng, trực quan hơn.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.meeting_room_rounded,
                  label: 'Loại phòng',
                  value: '${data.roomTypes.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bed_rounded,
                  label: 'Phòng có sẵn',
                  value: '${data.rooms.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceptionHeader extends StatelessWidget {
  const _ReceptionHeader({
    required this.selectedDate,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final VoidCallback onPickDate;

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
            'Bảng lễ tân',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Xem booking theo ngày và chỉ hiện nút Checkin/Checkout đúng thời điểm.',
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
              _Badge(label: 'PENDING', color: scheme.tertiary),
              const SizedBox(width: 8),
              _Badge(label: 'CHECKED_IN', color: scheme.primary),
              const SizedBox(width: 8),
              _Badge(label: 'CHECKED_OUT', color: Colors.green),
            ],
          ),
        ],
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
