import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/viewmodel/auth_viewmodel.dart';
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

  @override
  void initState() {
    super.initState();
    _homepageFuture = BookingApi.getHomepage();
  }

  Future<void> _reload() async {
    setState(() {
      _homepageFuture = BookingApi.getHomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Get.find<AuthViewModel>();
    final username = authVm.currentUser.value?.username ?? 'khách';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Hotel Booking'),
        backgroundColor: Colors.transparent,
        actions: [
          if (authVm.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: authVm.logout,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => Get.toNamed('/login'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Đăng nhập',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFB347),
              const Color(0xFFFFD6A5),
              const Color(0xFFFFF4E6),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<HomepageData>(
            future: _homepageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 24),
                  children: [_ErrorCard(onRetry: _reload)],
                );
              }

              final data = snapshot.data ?? HomepageData.empty();
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _GuestHeader(data: data, username: username),
                  const SizedBox(height: 18),
                  Text(
                    'Loại phòng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                          imagePath: roomType.imagePath,
                          onTap: () async {
                            if (!context.mounted) return;

                            final changed = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => RoomTypeDetailPage(
                                      roomType: roomType,
                                      availableRooms: data.rooms
                                          .where(
                                            (room) =>
                                                room.roomTypeId ==
                                                roomType.roomTypeId,
                                          )
                                          .toList(),
                                    ),
                                  ),
                                );

                            if (changed == true || changed == null) {
                              await _reload();
                            }
                          },
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

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({required this.data, required this.username});

  final HomepageData data;
  final String username;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'FPT Golden Hotel',
              style: TextStyle(
                color: Color(0xFFE36C00),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Xin chào, $username',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB85C00),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chào mừng đến với Khách sạn FPT Goden, khách sạn 5 sao hàng đầu Việt Nam.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB85C00),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Không gian sang trọng, ấm áp với tông màu cam nổi bật, mang đến trải nghiệm đẳng cấp và thân thiện cho khách hàng.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              height: 1.5,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                );
              },
              icon: const Icon(Icons.receipt_long_rounded),
              label: const Text('Lịch sử đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<BookingSummary>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _loadBookings();
  }

  Future<List<BookingSummary>> _loadBookings() async {
    final authVm = Get.find<AuthViewModel>();
    return BookingApi.getBookings(userId: authVm.currentUser.value?.userId);
  }

  Future<void> _reload() async {
    setState(() {
      _bookingsFuture = _loadBookings();
    });
  }

  Future<void> _requestCancel(BookingSummary booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu hủy đơn hàng'),
        content: Text(
          'Bạn có chắc muốn gửi yêu cầu hủy booking ${booking.bookingId} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await BookingApi.requestCancelBooking(booking.bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu hủy, trạng thái chuyển sang đợi duyệt'),
        ),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gửi yêu cầu hủy thất bại: $e')));
    }
  }

  Future<void> _cancelCancelRequest(BookingSummary booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy yêu cầu hủy'),
        content: Text(
          'Bạn có chắc muốn hủy yêu cầu hủy booking ${booking.bookingId} không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await BookingApi.cancelCancelRequest(booking.bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy yêu cầu hủy booking')),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hủy yêu cầu hủy thất bại: $e')));
    }
  }

  Future<void> _changeRoom(BookingSummary booking) async {
    try {
      final rooms = await BookingApi.getChangeableRooms(booking.bookingId);
      if (!mounted) return;

      if (rooms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có phòng nào khả dụng để thay đổi'),
          ),
        );
        return;
      }

      final roomTypeId = rooms.first.roomTypeId;
      final roomTypeName = rooms.first.roomTypeName ?? 'Loại phòng';
      final availableRooms = rooms
          .where((room) => room.roomTypeId == roomTypeId)
          .toList();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingFormPage(
            roomType: RoomTypeModel(
              roomTypeId: roomTypeId,
              name: roomTypeName,
              description: rooms.first.description ?? '',
              basePrice: rooms.first.basePrice ?? 0,
              imagePath: rooms.first.imagePath ?? '',
            ),
            availableRooms: availableRooms,
            prefillBooking: booking,
            initialGuestName: booking.guestName,
            initialPhone: booking.phone,
            initialEmail: booking.email,
            initialCheckin: DateTime.tryParse(booking.expectedCheckin),
            initialCheckout: DateTime.tryParse(booking.expectedCheckout),
            initialSelectedRoomId: booking.rooms.isNotEmpty
                ? _extractRoomId(booking.rooms.first)
                : null,
            lockDates: true,
            changeBookingId: booking.bookingId,
            dialogMode: true,
            onBookingChanged: (_) async {
              await _reload();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thay đổi phòng thất bại: $e')));
    }
  }

  String? _extractRoomId(String roomLabel) {
    final match = RegExp(r'\(([^)]+)\)$').firstMatch(roomLabel.trim());
    if (match != null) {
      return match.group(1)?.trim();
    }
    return roomLabel.trim().isEmpty ? null : roomLabel.trim();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng'),
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

              final bookings = snapshot.data ?? [];
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _OrderHistoryHeader(totalBookings: bookings.length),
                  const SizedBox(height: 18),
                  if (bookings.isEmpty)
                    const Text('Chưa có đơn hàng nào')
                  else
                    ...bookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderHistoryCard(
                          booking: booking,
                          onRequestCancel:
                              booking.canRequestCancel &&
                                  !booking.hasReachedCheckinDeadline
                              ? () => _requestCancel(booking)
                              : null,
                          onCancelCancelRequest: booking.canCancelCancelRequest
                              ? () => _cancelCancelRequest(booking)
                              : null,
                          onChangeRoom:
                              booking.rooms.isNotEmpty &&
                                  !booking.isWaitingCancelApproval &&
                                  !booking.isCancelled
                              ? () => _changeRoom(booking)
                              : null,
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

class _OrderHistoryHeader extends StatelessWidget {
  const _OrderHistoryHeader({required this.totalBookings});

  final int totalBookings;

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
            'Lịch sử đơn hàng',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Xem thông tin booking, cập nhật đơn hàng hoặc gửi yêu cầu hủy để lễ tân duyệt.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _Badge(label: '$totalBookings booking', color: Colors.orange),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({
    required this.booking,
    required this.onRequestCancel,
    required this.onCancelCancelRequest,
    required this.onChangeRoom,
  });

  final BookingSummary booking;
  final VoidCallback? onRequestCancel;
  final VoidCallback? onCancelCancelRequest;
  final VoidCallback? onChangeRoom;

  String get _statusText {
    if (booking.isWaitingCancelApproval) return 'Đợi lễ tân duyệt hủy';
    if (booking.isCancelled) return 'Đơn hàng đã hủy';
    if (booking.isCancelRejected) return 'Yêu cầu hủy đã từ chối';
    if (booking.canRequestCancel && booking.hasReachedCheckinDeadline) {
      return 'Đã đến hạn check-in, không thể hủy đơn hàng';
    }
    return booking.status;
  }

  Color _statusColor(BuildContext context) {
    if (booking.isWaitingCancelApproval) return Colors.orange;
    if (booking.isCancelled) return Colors.red;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final actionCallback = booking.isWaitingCancelApproval
        ? onCancelCancelRequest
        : onRequestCancel;
    final actionLabel = booking.isWaitingCancelApproval
        ? 'Hủy'
        : 'Hủy đơn hàng';
    final actionIcon = booking.isWaitingCancelApproval
        ? Icons.undo_rounded
        : Icons.cancel_schedule_send_rounded;
    final disableCancel =
        !booking.isWaitingCancelApproval &&
        booking.canRequestCancel &&
        booking.hasReachedCheckinDeadline;

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
          Text('Checkin: ${booking.expectedCheckin}'),
          Text('Checkout: ${booking.expectedCheckout}'),
          Text('Tổng tiền: ${booking.totalAmount ?? 0}'),
          const SizedBox(height: 8),
          _Badge(label: _statusText, color: _statusColor(context)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: disableCancel
                  ? null
                  : () {
                      if (booking.hasReachedCheckinDeadline &&
                          !booking.isWaitingCancelApproval) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã đến hạn check-in, không thể hủy đơn hàng',
                            ),
                          ),
                        );
                        return;
                      }
                      actionCallback?.call();
                    },
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChangeRoom,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Thay đổi đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }
}

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
      userId: Get.find<AuthViewModel>().currentUser.value?.userId,
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
        userId: Get.find<AuthViewModel>().currentUser.value?.userId,
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
        userId: Get.find<AuthViewModel>().currentUser.value?.userId,
      );
    });
  }

  Future<void> _changeStatus(String bookingId, String status) async {
    await BookingApi.updateBookingStatus(bookingId, status);
    if (!mounted) return;
    setState(() {
      _bookingsFuture = BookingApi.getBookings(
        date: _formatDate(_selectedDate),
        userId: Get.find<AuthViewModel>().currentUser.value?.userId,
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
