import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/booking_viewmodel.dart';
import '../widgets/room_type_card.dart';
import 'booking_pages.dart';

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key, this.homepageFuture});

  final Future<HomepageData>? homepageFuture;

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  late Future<HomepageData> _homepageFuture;
  Future<List<BookingSummary>>? _userBookingsFuture;
  int _selectedIndex = 0;
  String _roomTypeQuery = '';

  @override
  void initState() {
    super.initState();
    _homepageFuture = widget.homepageFuture ?? BookingApi.getHomepage();
  }

  Future<void> _reload() async {
    setState(() {
      _homepageFuture = BookingApi.getHomepage();
      _userBookingsFuture = null;
    });
  }

  Future<List<BookingSummary>> _loadUserBookings() {
    final authVm = Get.find<AuthViewModel>();
    return BookingApi.getBookings(userId: authVm.currentUser.value?.userId);
  }

  Future<List<BookingSummary>> _ensureUserBookingsFuture() {
    return _userBookingsFuture ??= _loadUserBookings();
  }

  Future<void> _reloadUserBookings() async {
    setState(() {
      _userBookingsFuture = _loadUserBookings();
    });
  }

  String get _title {
    switch (_selectedIndex) {
      case 1:
        return 'Quản lý đặt phòng';
      case 2:
        return 'Lịch sử đặt phòng';
      case 3:
        return 'Hồ sơ cá nhân';
      default:
        return 'Tìm phòng';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Get.find<AuthViewModel>();
    final fullName = authVm.currentUser.value?.fullName ?? 'Khách';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_title),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_rounded),
            label: 'Đặt phòng',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFB86B),
              Color(0xFFFFE6C7),
              Color(0xFFF5FAFF),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _selectedIndex == 0 ? _reload : _reloadUserBookings,
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
              switch (_selectedIndex) {
                case 1:
                  return _BookingManagementTab(
                    bookingsFuture: _ensureUserBookingsFuture(),
                    onRefresh: _reloadUserBookings,
                  );
                case 2:
                  return _BookingHistoryTab(
                    bookingsFuture: _ensureUserBookingsFuture(),
                    onRefresh: _reloadUserBookings,
                  );
                case 3:
                  return const _UserProfileTab();
                default:
                  return _SearchRoomTypeTab(
                    data: data,
                    fullName: fullName,
                    query: _roomTypeQuery,
                    onQueryChanged: (value) {
                      setState(() {
                        _roomTypeQuery = value;
                      });
                    },
                    onRoomChanged: _reload,
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({required this.data, required this.fullName});

  final HomepageData data;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
            'Xin chào, $fullName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB85C00),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chào mừng đến với Khách sạn FPT Golden.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB85C00),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tìm phòng phù hợp, xem đánh giá và đặt phòng chỉ trong vài bước.',
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
        ],
      ),
    );
  }
}

class _SearchRoomTypeTab extends StatefulWidget {
  const _SearchRoomTypeTab({
    required this.data,
    required this.fullName,
    required this.query,
    required this.onQueryChanged,
    required this.onRoomChanged,
  });

  final HomepageData data;
  final String fullName;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function() onRoomChanged;

  @override
  State<_SearchRoomTypeTab> createState() => _SearchRoomTypeTabState();
}

class _SearchRoomTypeTabState extends State<_SearchRoomTypeTab> {
  final TextEditingController _checkinController = TextEditingController();
  final TextEditingController _checkoutController = TextEditingController();
  final TextEditingController _guestController = TextEditingController(
    text: '2',
  );

  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  List<RoomModel>? _searchedRooms;
  bool _searching = false;

  @override
  void dispose() {
    _checkinController.dispose();
    _checkoutController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  String _formatDateForApi(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _formatDateForDisplay(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  Future<void> _pickDate({required bool isCheckin}) async {
    final now = DateTime.now();
    final initialDate = isCheckin
        ? (_checkinDate ?? now)
        : (_checkoutDate ?? _checkinDate ?? now.add(const Duration(days: 1)));
    final firstDate = isCheckin ? now : (_checkinDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
      helpText: isCheckin ? 'Chọn ngày nhận phòng' : 'Chọn ngày trả phòng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked == null) return;

    setState(() {
      if (isCheckin) {
        _checkinDate = picked;
        _checkinController.text = _formatDateForDisplay(picked);
        if (_checkoutDate != null && !_checkoutDate!.isAfter(picked)) {
          _checkoutDate = null;
          _checkoutController.clear();
        }
      } else {
        _checkoutDate = picked;
        _checkoutController.text = _formatDateForDisplay(picked);
      }
    });
  }

  Future<void> _searchAvailableRooms() async {
    final checkin = _checkinDate;
    final checkout = _checkoutDate;
    final guests = int.tryParse(_guestController.text.trim());

    if (checkin == null || checkout == null || !checkout.isAfter(checkin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày nhận/trả phòng hợp lệ'),
        ),
      );
      return;
    }
    if (guests == null || guests <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số khách phải lớn hơn 0')));
      return;
    }

    setState(() {
      _searching = true;
    });

    try {
      final rooms = await BookingApi.getAvailableRooms(
        checkin: _formatDateForApi(checkin),
        checkout: _formatDateForApi(checkout),
      );
      if (!mounted) return;
      setState(() {
        _searchedRooms = rooms;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không tìm được phòng: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = widget.query.trim().toLowerCase();
    final availableRooms = _searchedRooms ?? widget.data.rooms;
    final roomTypes = widget.data.roomTypes
        .where((roomType) {
          if (normalizedQuery.isEmpty) return true;
          return roomType.name.toLowerCase().contains(normalizedQuery) ||
              roomType.description.toLowerCase().contains(normalizedQuery);
        })
        .where((roomType) {
          if (_searchedRooms == null) return true;
          return availableRooms.any(
            (room) => room.roomTypeId == roomType.roomTypeId,
          );
        })
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
      children: [
        _GuestHeader(data: widget.data, fullName: widget.fullName),
        const SizedBox(height: 18),
        _BookingPanel(
          icon: Icons.travel_explore_rounded,
          title: 'Tìm phòng phù hợp',
          subtitle: 'Chọn ngày lưu trú và số khách để xem phòng còn trống.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _checkinController,
                readOnly: true,
                onTap: () => _pickDate(isCheckin: true),
                decoration: const InputDecoration(
                  labelText: 'Ngày nhận phòng',
                  hintText: 'Chọn ngày nhận phòng',
                  suffixIcon: Icon(Icons.calendar_month_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _checkoutController,
                readOnly: true,
                onTap: () => _pickDate(isCheckin: false),
                decoration: const InputDecoration(
                  labelText: 'Ngày trả phòng',
                  hintText: 'Chọn ngày trả phòng',
                  suffixIcon: Icon(Icons.event_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _guestController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số khách',
                  prefixIcon: Icon(Icons.group_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: widget.onQueryChanged,
                decoration: const InputDecoration(
                  labelText: 'Loại phòng',
                  hintText: 'Suite, Deluxe, Superior...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _searching ? null : _searchAvailableRooms,
                  icon: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: const Text('Tìm phòng'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _BookingPanel(
          icon: Icons.king_bed_rounded,
          title: 'Loại phòng còn trống',
          subtitle: _searchedRooms == null
              ? 'Danh sách loại phòng hiện có trong khách sạn.'
              : 'Kết quả phù hợp với ngày lưu trú vừa chọn.',
          trailing: _searchedRooms != null
              ? _Badge(
                  label: '${availableRooms.length} phòng',
                  color: Colors.blueGrey,
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roomTypes.isEmpty)
                const _EmptyHint(
                  icon: Icons.search_off_rounded,
                  title: 'Không tìm thấy loại phòng phù hợp',
                  message: 'Hãy thử đổi ngày lưu trú hoặc từ khóa loại phòng.',
                )
              else
                ...roomTypes.map((roomType) {
                  final roomsForType = availableRooms
                      .where((room) => room.roomTypeId == roomType.roomTypeId)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoomTypeCard(
                      title: roomType.name,
                      subtitle: roomType.description,
                      imagePath: roomType.imagePath,
                      priceLabel: '${_formatMoney(roomType.basePrice)} / đêm',
                      availableCount: roomsForType.length,
                      onTap: () async {
                        if (!context.mounted) return;

                        final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => RoomTypeDetailPage(
                              roomType: roomType,
                              availableRooms: roomsForType,
                              initialCheckin: _checkinDate,
                              initialCheckout: _checkoutDate,
                              initialGuestCount: int.tryParse(
                                _guestController.text.trim(),
                              ),
                              onViewFeedback: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FeedbackListPage(),
                                  ),
                                );
                              },
                              onSubmitFeedback: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SubmitFeedbackPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );

                        if (changed == true || changed == null) {
                          await widget.onRoomChanged();
                        }
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingPanel extends StatelessWidget {
  const _BookingPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BookingManagementTab extends StatelessWidget {
  const _BookingManagementTab({
    required this.bookingsFuture,
    required this.onRefresh,
  });

  final Future<List<BookingSummary>> bookingsFuture;
  final Future<void> Function() onRefresh;

  Future<void> _openBookingDetail(
    BuildContext context,
    BookingSummary booking,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingDetailPage(booking: booking)),
    );
    await onRefresh();
  }

  Future<void> _requestCancelBooking(
    BuildContext context,
    BookingSummary booking,
  ) async {
    final formData = await showDialog<_CancellationFormData>(
      context: context,
      builder: (context) => _BookingCancellationDialog(booking: booking),
    );

    if (formData == null) return;

    try {
      final updated = await BookingApi.requestCancelBooking(booking.bookingId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi yêu cầu hủy đặt phòng ${updated.bookingId}. Lý do: ${formData.reason}',
          ),
        ),
      );
      await onRefresh();
    } catch (e) {
      if (!context.mounted) return;
      final message = BookingApi.errorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi yêu cầu hủy thất bại: $message')),
      );
    }
  }

  bool _isCurrentBooking(BookingSummary booking) {
    final status = booking.status.toUpperCase();
    return status != 'CANCELLED' &&
        status != 'CHECKED_OUT' &&
        status != 'COMPLETED';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingSummary>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            children: [_ErrorCard(onRetry: onRefresh)],
          );
        }

        final currentBookings = (snapshot.data ?? [])
            .where(_isCurrentBooking)
            .toList();

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          children: [
            _TaskSectionCard(
              title: 'Quản lý đặt phòng',
              subtitle:
                  'Xem chi tiết đặt phòng hiện tại và gọi dịch vụ cho kỳ lưu trú.',
              icon: Icons.book_online_rounded,
              child: _Badge(
                label: '${currentBookings.length} đặt phòng hiện tại',
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Đặt phòng hiện tại',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (currentBookings.isEmpty)
              const Text('Chưa có đặt phòng hiện tại')
            else
              ...currentBookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CompactBookingCard(
                    booking: booking,
                    onViewDetails: () => _openBookingDetail(context, booking),
                    onCancel: booking.canRequestCancel
                        ? () => _requestCancelBooking(context, booking)
                        : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BookingHistoryTab extends StatelessWidget {
  const _BookingHistoryTab({
    required this.bookingsFuture,
    required this.onRefresh,
  });

  final Future<List<BookingSummary>> bookingsFuture;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingSummary>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            children: [_ErrorCard(onRetry: onRefresh)],
          );
        }

        final bookings = snapshot.data ?? [];
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          children: [
            _TaskSectionCard(
              title: 'Lịch sử đặt phòng',
              subtitle:
                  'Xem lại tất cả đặt phòng được tạo bằng tài khoản của bạn.',
              icon: Icons.history_rounded,
              child: _Badge(
                label: '${bookings.length} đặt phòng',
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 18),
            if (bookings.isEmpty)
              const Text('Chưa có lịch sử đặt phòng')
            else
              _BookingHistoryTable(bookings: bookings),
          ],
        );
      },
    );
  }
}

class _BookingHistoryTable extends StatelessWidget {
  const _BookingHistoryTable({required this.bookings});

  final List<BookingSummary> bookings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: bookings
          .map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HistoryBookingCard(booking: booking),
            ),
          )
          .toList(),
    );
  }
}

class _HistoryBookingCard extends StatelessWidget {
  const _HistoryBookingCard({required this.booking});

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  booking.bookingId,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Badge(
                label: _bookingStatusText(booking.status),
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BookingInfoLine(
            icon: Icons.calendar_month_rounded,
            label: 'Lưu trú',
            value: '${booking.expectedCheckin} - ${booking.expectedCheckout}',
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.meeting_room_rounded,
            label: 'Phòng',
            value: booking.rooms.isEmpty
                ? 'Chưa có thông tin'
                : booking.rooms.join(', '),
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.payments_rounded,
            label: 'Tổng tiền',
            value: _formatMoney(_moneyValue(booking.totalAmount)),
          ),
        ],
      ),
    );
  }
}

class _BookingInfoLine extends StatelessWidget {
  const _BookingInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _UserProfileTab extends StatelessWidget {
  const _UserProfileTab();

  @override
  Widget build(BuildContext context) {
    final authVm = Get.find<AuthViewModel>();
    final user = authVm.currentUser.value;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
      children: [
        _TaskSectionCard(
          title: 'Hồ sơ cá nhân',
          subtitle: user == null
              ? 'Đăng nhập để quản lý hồ sơ đặt phòng.'
              : 'Quản lý thông tin tài khoản dùng để đặt phòng.',
          icon: Icons.person_rounded,
          child: user == null
              ? SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Get.toNamed('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Đăng nhập'),
                  ),
                )
              : Column(
                  children: [
                    _ProfileRow(label: 'Họ tên', value: user.fullName),
                    _ProfileRow(label: 'Tên đăng nhập', value: user.username),
                    _ProfileRow(label: 'Email', value: user.email),
                    _ProfileRow(label: 'Số điện thoại', value: user.phone),
                    _ProfileRow(
                      label: 'Vai trò',
                      value: user.roles.isEmpty
                          ? 'Khách'
                          : user.roles.join(', '),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: authVm.logout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Đăng xuất'),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _TaskSectionCard extends StatelessWidget {
  const _TaskSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

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
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CompactBookingCard extends StatelessWidget {
  const _CompactBookingCard({
    required this.booking,
    this.onViewDetails,
    this.onCancel,
  });

  final BookingSummary booking;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.guestName.isEmpty
                      ? booking.bookingId
                      : booking.guestName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Badge(
                label: _bookingStatusText(booking.status),
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Mã đặt phòng: ${booking.bookingId}'),
          if (booking.rooms.isNotEmpty)
            Text('Phòng: ${booking.rooms.join(", ")}'),
          Text('Ngày nhận phòng: ${booking.expectedCheckin}'),
          Text('Ngày trả phòng: ${booking.expectedCheckout}'),
          Text('Tổng tiền: ${_formatMoney(_moneyValue(booking.totalAmount))}'),
          if (onViewDetails != null || onCancel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onViewDetails != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Xem chi tiết'),
                    ),
                  ),
                if (onViewDetails != null && onCancel != null)
                  const SizedBox(width: 10),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_schedule_send_rounded),
                      label: const Text('Hủy đặt phòng'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingCancellationDialog extends StatefulWidget {
  const _BookingCancellationDialog({required this.booking});

  final BookingSummary booking;

  @override
  State<_BookingCancellationDialog> createState() =>
      _BookingCancellationDialogState();
}

class _BookingCancellationDialogState
    extends State<_BookingCancellationDialog> {
  static const _reasons = [
    'Thay đổi kế hoạch',
    'Đặt sai ngày',
    'Tìm được phòng khác',
    'Lý do cá nhân',
    'Khác',
  ];

  final TextEditingController _notesController = TextEditingController();
  String? _selectedReason;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _selectedReason;
    if (reason == null || reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lý do hủy')));
      return;
    }

    Navigator.of(context).pop(
      _CancellationFormData(
        reason: reason,
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return AlertDialog(
      title: const Text('Yêu cầu hủy đặt phòng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết đặt phòng',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text('Mã đặt phòng: ${booking.bookingId}'),
                  Text(
                    'Lưu trú: ${booking.expectedCheckin} - ${booking.expectedCheckout}',
                  ),
                  Text(
                    booking.rooms.isEmpty
                        ? 'Phòng: Chưa có thông tin'
                        : 'Phòng: ${booking.rooms.join(", ")}',
                  ),
                  Text(
                    'Tổng tiền: ${_formatMoney(_moneyValue(booking.totalAmount))}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              decoration: const InputDecoration(
                labelText: 'Lý do hủy (*)',
                border: OutlineInputBorder(),
              ),
              items: _reasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              maxLength: 250,
              decoration: const InputDecoration(
                labelText: 'Ghi chú thêm',
                hintText: 'Không bắt buộc: nhập thêm chi tiết...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Giữ đặt phòng'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Xác nhận hủy')),
      ],
    );
  }
}

class _CancellationFormData {
  const _CancellationFormData({required this.reason, required this.notes});

  final String reason;
  final String notes;
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Chưa cung cấp' : value)),
        ],
      ),
    );
  }
}

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, required this.booking});

  final BookingSummary booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late BookingSummary _booking;
  late Future<_BookingDetailData> _dataFuture;
  final Map<String, int> _quantities = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _dataFuture = _loadData();
  }

  Future<_BookingDetailData> _loadData() async {
    final servicesFuture = BookingApi.getServices();
    final ordersFuture = BookingApi.getServiceOrdersByBooking(
      _booking.bookingId,
    );
    return _BookingDetailData(
      services: await servicesFuture,
      orders: await ordersFuture,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  bool get _canMakeOrder {
    final status = _booking.status.toUpperCase();
    return status == 'PENDING' ||
        status == 'CONFIRMED' ||
        status == 'CHECKED_IN' ||
        status == 'CANCEL_REJECTED';
  }

  double _total(List<HotelServiceModel> services) {
    return services.fold<double>(0, (sum, service) {
      final quantity = _quantities[service.serviceId] ?? 0;
      return sum + service.price * quantity;
    });
  }

  Future<void> _requestCancelBooking() async {
    final formData = await showDialog<_CancellationFormData>(
      context: context,
      builder: (context) => _BookingCancellationDialog(booking: _booking),
    );

    if (formData == null) return;

    try {
      final updated = await BookingApi.requestCancelBooking(_booking.bookingId);
      if (!mounted) return;
      setState(() {
        _booking = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi yêu cầu hủy đặt phòng ${updated.bookingId}. Lý do: ${formData.reason}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = BookingApi.errorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi yêu cầu hủy thất bại: $message')),
      );
    }
  }

  Future<void> _cancelCancelRequest() async {
    try {
      final updated = await BookingApi.cancelCancelRequest(_booking.bookingId);
      if (!mounted) return;
      setState(() {
        _booking = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã giữ lại đặt phòng ${updated.bookingId}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hủy yêu cầu hủy thất bại: $e')));
    }
  }

  Future<void> _submitOrder(List<HotelServiceModel> services) async {
    final selectedServices = services
        .map(
          (service) => ServiceOrderLinePayload(
            serviceId: service.serviceId,
            quantity: _quantities[service.serviceId] ?? 0,
          ),
        )
        .where((line) => line.quantity > 0)
        .toList();

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một dịch vụ')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final order = await BookingApi.createServiceOrder(
        CreateServiceOrderPayload(
          bookingId: _booking.bookingId,
          services: selectedServices,
        ),
      );
      if (!mounted) return;
      setState(() {
        _quantities.clear();
        _dataFuture = _loadData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo đơn dịch vụ ${order.orderId}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gọi dịch vụ thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _cancelOrder(ServiceOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn dịch vụ'),
        content: Text('Bạn muốn hủy đơn dịch vụ ${order.orderId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await BookingApi.cancelServiceOrder(order.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hủy đơn dịch vụ ${order.orderId}')),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return _OrderScaffold(
      title: 'Chi tiết đặt phòng',
      child: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<_BookingDetailData>(
          future: _dataFuture,
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

            final data = snapshot.data ?? _BookingDetailData.empty();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              children: [
                _BookingDetailCard(
                  booking: _booking,
                  onRequestCancel: _booking.canRequestCancel
                      ? _requestCancelBooking
                      : null,
                  onCancelCancelRequest: _booking.canCancelCancelRequest
                      ? _cancelCancelRequest
                      : null,
                ),
                const SizedBox(height: 18),
                _InlineMakeOrderSection(
                  services: data.services,
                  quantities: _quantities,
                  total: _total(data.services),
                  canMakeOrder: _canMakeOrder,
                  submitting: _submitting,
                  onQuantityChanged: (serviceId, quantity) {
                    setState(() {
                      if (quantity <= 0) {
                        _quantities.remove(serviceId);
                      } else {
                        _quantities[serviceId] = quantity;
                      }
                    });
                  },
                  onSubmit: () => _submitOrder(data.services),
                ),
                const SizedBox(height: 18),
                _BookingOrderListSection(
                  orders: data.orders,
                  onCancel: _cancelOrder,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingDetailData {
  const _BookingDetailData({required this.services, required this.orders});

  final List<HotelServiceModel> services;
  final List<ServiceOrderModel> orders;

  factory _BookingDetailData.empty() =>
      const _BookingDetailData(services: [], orders: []);
}

class _BookingDetailCard extends StatelessWidget {
  const _BookingDetailCard({
    required this.booking,
    required this.onRequestCancel,
    required this.onCancelCancelRequest,
  });

  final BookingSummary booking;
  final VoidCallback? onRequestCancel;
  final VoidCallback? onCancelCancelRequest;

  @override
  Widget build(BuildContext context) {
    return _TaskSectionCard(
      title: 'Chi tiết đặt phòng',
      subtitle: 'Thông tin lưu trú và trạng thái đặt phòng.',
      icon: Icons.receipt_long_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.bookingId,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Badge(
                label: _bookingStatusText(booking.status),
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BookingInfoLine(
            icon: Icons.person_rounded,
            label: 'Khách',
            value: booking.guestName,
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.phone_rounded,
            label: 'SĐT',
            value: booking.phone,
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.calendar_month_rounded,
            label: 'Lưu trú',
            value: '${booking.expectedCheckin} - ${booking.expectedCheckout}',
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.meeting_room_rounded,
            label: 'Phòng',
            value: booking.rooms.isEmpty
                ? 'Chưa có thông tin phòng'
                : booking.rooms.join(', '),
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.payments_rounded,
            label: 'Tổng tiền',
            value: _formatMoney(_moneyValue(booking.totalAmount)),
          ),
          if (onRequestCancel != null || onCancelCancelRequest != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: booking.canCancelCancelRequest
                  ? OutlinedButton.icon(
                      onPressed: onCancelCancelRequest,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Giữ đặt phòng'),
                    )
                  : OutlinedButton.icon(
                      onPressed: onRequestCancel,
                      icon: const Icon(Icons.cancel_schedule_send_rounded),
                      label: const Text('Hủy đặt phòng'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineMakeOrderSection extends StatelessWidget {
  const _InlineMakeOrderSection({
    required this.services,
    required this.quantities,
    required this.total,
    required this.canMakeOrder,
    required this.submitting,
    required this.onQuantityChanged,
    required this.onSubmit,
  });

  final List<HotelServiceModel> services;
  final Map<String, int> quantities;
  final double total;
  final bool canMakeOrder;
  final bool submitting;
  final void Function(String serviceId, int quantity) onQuantityChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _TaskSectionCard(
      title: 'Gọi dịch vụ',
      subtitle: 'Chọn dịch vụ cho đặt phòng này.',
      icon: Icons.room_service_rounded,
      child: Column(
        children: [
          if (!canMakeOrder)
            const Text('Trạng thái đặt phòng này không thể gọi dịch vụ.')
          else if (services.isEmpty)
            const Text('Chưa có dịch vụ khả dụng')
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceCatalogTile(
                  service: service,
                  quantity: quantities[service.serviceId] ?? 0,
                  onChanged: (quantity) =>
                      onQuantityChanged(service.serviceId, quantity),
                ),
              ),
            ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ServiceOrderSummaryCard(
              services: services,
              quantities: quantities,
              total: total,
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !canMakeOrder || submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_rounded),
              label: const Text('Đặt dịch vụ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingOrderListSection extends StatelessWidget {
  const _BookingOrderListSection({
    required this.orders,
    required this.onCancel,
  });

  final List<ServiceOrderModel> orders;
  final Future<void> Function(ServiceOrderModel order) onCancel;

  @override
  Widget build(BuildContext context) {
    return _TaskSectionCard(
      title: 'Chi tiết đơn dịch vụ',
      subtitle: 'Các đơn dịch vụ đã tạo cho đặt phòng này.',
      icon: Icons.list_alt_rounded,
      child: Column(
        children: [
          if (orders.isEmpty)
            const Text('Đặt phòng này chưa có đơn dịch vụ')
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceOrderCard(
                  order: order,
                  onCancel: order.canGuestCancel ? () => onCancel(order) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MakeServiceOrderPage extends StatefulWidget {
  const MakeServiceOrderPage({super.key});

  @override
  State<MakeServiceOrderPage> createState() => _MakeServiceOrderPageState();
}

class _MakeServiceOrderPageState extends State<MakeServiceOrderPage> {
  late Future<_MakeServiceOrderData> _dataFuture;
  final Map<String, int> _quantities = {};
  String? _selectedBookingId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_MakeServiceOrderData> _loadData() async {
    final authVm = Get.find<AuthViewModel>();
    final bookingsFuture = BookingApi.getBookings(
      userId: authVm.currentUser.value?.userId,
    );
    final servicesFuture = BookingApi.getServices();
    return _MakeServiceOrderData(
      bookings: await bookingsFuture,
      services: await servicesFuture,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  double _total(List<HotelServiceModel> services) {
    return services.fold<double>(0, (sum, service) {
      final quantity = _quantities[service.serviceId] ?? 0;
      return sum + service.price * quantity;
    });
  }

  Future<void> _submit(List<HotelServiceModel> services) async {
    final bookingId = _selectedBookingId;
    final selectedServices = services
        .map(
          (service) => ServiceOrderLinePayload(
            serviceId: service.serviceId,
            quantity: _quantities[service.serviceId] ?? 0,
          ),
        )
        .where((line) => line.quantity > 0)
        .toList();

    if (bookingId == null || bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đặt phòng trước')),
      );
      return;
    }
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một dịch vụ')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final order = await BookingApi.createServiceOrder(
        CreateServiceOrderPayload(
          bookingId: bookingId,
          services: selectedServices,
        ),
      );
      if (!mounted) return;
      setState(() {
        _quantities.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo đơn dịch vụ ${order.orderId}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gọi dịch vụ thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _OrderScaffold(
      title: 'Gọi dịch vụ',
      child: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<_MakeServiceOrderData>(
          future: _dataFuture,
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

            final data = snapshot.data ?? _MakeServiceOrderData.empty();
            final activeBookings = data.bookings.where((booking) {
              final status = booking.status.toUpperCase();
              return status == 'PENDING' ||
                  status == 'CONFIRMED' ||
                  status == 'CHECKED_IN' ||
                  status == 'CANCEL_REJECTED';
            }).toList();
            final selectedExists = activeBookings.any(
              (booking) => booking.bookingId == _selectedBookingId,
            );

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              children: [
                _ServiceOrderHeader(
                  title: 'Gọi dịch vụ',
                  subtitle: 'Khách chọn đặt phòng và các dịch vụ cần đặt.',
                  badge: 'Tổng tiền: ${_formatMoney(_total(data.services))}',
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: selectedExists ? _selectedBookingId : null,
                  decoration: const InputDecoration(
                    labelText: 'Đặt phòng',
                    border: OutlineInputBorder(),
                  ),
                  items: activeBookings
                      .map(
                        (booking) => DropdownMenuItem(
                          value: booking.bookingId,
                          child: Text(
                            '${booking.bookingId} - ${booking.guestName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBookingId = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                if (activeBookings.isEmpty)
                  const Text(
                    'Vui lòng tạo đặt phòng đang hoạt động trước khi gọi dịch vụ',
                  )
                else if (data.services.isEmpty)
                  const Text('Chưa có dịch vụ khả dụng')
                else
                  ...data.services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCatalogTile(
                        service: service,
                        quantity: _quantities[service.serviceId] ?? 0,
                        onChanged: (quantity) {
                          setState(() {
                            if (quantity <= 0) {
                              _quantities.remove(service.serviceId);
                            } else {
                              _quantities[service.serviceId] = quantity;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                if (data.services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ServiceOrderSummaryCard(
                    services: data.services,
                    quantities: _quantities,
                    total: _total(data.services),
                  ),
                ],
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _submitting || activeBookings.isEmpty
                      ? null
                      : () => _submit(data.services),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: const Text('Đặt dịch vụ'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceOrderSummaryCard extends StatelessWidget {
  const _ServiceOrderSummaryCard({
    required this.services,
    required this.quantities,
    required this.total,
  });

  final List<HotelServiceModel> services;
  final Map<String, int> quantities;
  final double total;

  @override
  Widget build(BuildContext context) {
    final selectedServices = services
        .where((service) => (quantities[service.serviceId] ?? 0) > 0)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF94A3B8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TÓM TẮT ĐƠN DỊCH VỤ',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Divider(height: 22),
          if (selectedServices.isEmpty)
            const Text('Chưa chọn dịch vụ nào')
          else
            ...selectedServices.map((service) {
              final quantity = quantities[service.serviceId] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${service.serviceName} x $quantity')),
                    Text(_formatMoney(service.price * quantity)),
                  ],
                ),
              );
            }),
          const Divider(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TỔNG CHI PHÍ:',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                _formatMoney(total),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CancelServiceOrderPage extends StatefulWidget {
  const CancelServiceOrderPage({super.key});

  @override
  State<CancelServiceOrderPage> createState() => _CancelServiceOrderPageState();
}

class _CancelServiceOrderPageState extends State<CancelServiceOrderPage> {
  late Future<List<ServiceOrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadUserServiceOrders();
  }

  Future<List<ServiceOrderModel>> _loadUserServiceOrders() async {
    final authVm = Get.find<AuthViewModel>();
    final bookings = await BookingApi.getBookings(
      userId: authVm.currentUser.value?.userId,
    );
    final bookingIds = bookings.map((booking) => booking.bookingId).toSet();
    final orders = await BookingApi.getServiceOrders();
    return orders
        .where((order) => bookingIds.contains(order.bookingId))
        .toList();
  }

  Future<void> _reload() async {
    setState(() {
      _ordersFuture = _loadUserServiceOrders();
    });
  }

  Future<void> _cancel(ServiceOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn dịch vụ'),
        content: Text('Bạn muốn hủy đơn dịch vụ ${order.orderId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await BookingApi.cancelServiceOrder(order.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hủy đơn dịch vụ ${order.orderId}')),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return _ServiceOrderListBody(
      title: 'Hủy đơn dịch vụ',
      subtitle: 'Khách có thể hủy đơn dịch vụ sau khi lễ tân duyệt.',
      ordersFuture: _ordersFuture,
      onRefresh: _reload,
      onCancel: _cancel,
    );
  }
}

class _MakeServiceOrderData {
  const _MakeServiceOrderData({required this.bookings, required this.services});

  final List<BookingSummary> bookings;
  final List<HotelServiceModel> services;

  factory _MakeServiceOrderData.empty() =>
      const _MakeServiceOrderData(bookings: [], services: []);
}

class _ServiceOrderListBody extends StatelessWidget {
  const _ServiceOrderListBody({
    required this.title,
    required this.subtitle,
    required this.ordersFuture,
    required this.onRefresh,
    this.onCancel,
  });

  final String title;
  final String subtitle;
  final Future<List<ServiceOrderModel>> ordersFuture;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ServiceOrderModel order)? onCancel;

  @override
  Widget build(BuildContext context) {
    return _OrderScaffold(
      title: title,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<List<ServiceOrderModel>>(
          future: ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [_ErrorCard(onRetry: onRefresh)],
              );
            }

            final orders = snapshot.data ?? [];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              children: [
                _ServiceOrderHeader(
                  title: title,
                  subtitle: subtitle,
                  badge: '${orders.length} orders',
                ),
                const SizedBox(height: 18),
                if (orders.isEmpty)
                  const Text('Chưa có đơn dịch vụ')
                else
                  ...orders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceOrderCard(
                        order: order,
                        onCancel: onCancel == null || !order.canGuestCancel
                            ? null
                            : () => onCancel!(order),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderScaffold extends StatelessWidget {
  const _OrderScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
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
        child: child,
      ),
    );
  }
}

class _ServiceOrderHeader extends StatelessWidget {
  const _ServiceOrderHeader({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

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
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _Badge(label: badge, color: Colors.orange),
        ],
      ),
    );
  }
}

class _ServiceCatalogTile extends StatelessWidget {
  const _ServiceCatalogTile({
    required this.service,
    required this.quantity,
    required this.onChanged,
  });

  final HotelServiceModel service;
  final int quantity;
  final ValueChanged<int> onChanged;

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
          Icon(Icons.room_service_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (service.description.isNotEmpty) Text(service.description),
                Text(_formatMoney(service.price)),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: quantity <= 0 ? null : () => onChanged(quantity - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton.filled(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _ServiceOrderCard extends StatelessWidget {
  const _ServiceOrderCard({required this.order, required this.onCancel});

  final ServiceOrderModel order;
  final VoidCallback? onCancel;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  order.guestName.isEmpty ? order.bookingId : order.guestName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Badge(
                label: _orderStatusText(order.status),
                color: _orderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Mã đơn: ${order.orderId}'),
          Text('Mã đặt phòng: ${order.bookingId}'),
          Text('SĐT: ${order.phone}'),
          Text('Tổng tiền: ${_formatMoney(order.totalAmount)}'),
          if (order.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...order.services.map(
              (line) => Text(
                '${line.serviceName} x${line.quantity} - ${_formatMoney(line.lineTotal)}',
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_schedule_send_rounded),
                label: const Text('Hủy đơn dịch vụ'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _orderStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return Colors.green;
    case 'CANCELLED':
      return Colors.red;
    case 'IN_PROGRESS':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

String _bookingStatusText(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Đang chờ';
    case 'CONFIRMED':
      return 'Đã xác nhận';
    case 'CHECKED_IN':
      return 'Đã nhận phòng';
    case 'CHECKED_OUT':
    case 'COMPLETED':
      return 'Đã trả phòng';
    case 'WAITING_APPROVAL':
      return 'Đợi duyệt hủy';
    case 'CANCEL_REJECTED':
      return 'Từ chối hủy';
    case 'CANCELLED':
      return 'Đã hủy';
    default:
      return status;
  }
}

String _orderStatusText(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Đang chờ';
    case 'IN_PROGRESS':
      return 'Đang xử lý';
    case 'COMPLETED':
      return 'Hoàn tất';
    case 'CANCELLED':
      return 'Đã hủy';
    default:
      return status;
  }
}

String _roomStatusText(String status) {
  switch (status.toUpperCase()) {
    case 'AVAILABLE':
      return 'Còn trống';
    case 'BOOKED':
      return 'Đã đặt';
    case 'OCCUPIED':
      return 'Đang sử dụng';
    case 'MAINTENANCE':
      return 'Bảo trì';
    case 'DIRTY':
      return 'Cần dọn';
    case 'CLEANING':
      return 'Đang dọn';
    default:
      return status;
  }
}

String _formatMoney(num value) => '${value.toStringAsFixed(0)} VND';

num _moneyValue(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  late Future<List<FeedbackModel>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _feedbackFuture = BookingApi.getFeedbacks();
  }

  Future<void> _reload() async {
    setState(() {
      _feedbackFuture = BookingApi.getFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Đánh giá & phản hồi'),
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
          child: FutureBuilder<List<FeedbackModel>>(
            future: _feedbackFuture,
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

              final feedbacks = snapshot.data ?? [];
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _FeedbackHeader(totalFeedbacks: feedbacks.length),
                  const SizedBox(height: 18),
                  if (feedbacks.isEmpty)
                    const Text('Chưa có đánh giá nào')
                  else
                    ...feedbacks.map(
                      (feedback) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FeedbackCard(feedback: feedback),
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

class SubmitFeedbackPage extends StatefulWidget {
  const SubmitFeedbackPage({super.key});

  @override
  State<SubmitFeedbackPage> createState() => _SubmitFeedbackPageState();
}

class _SubmitFeedbackPageState extends State<SubmitFeedbackPage> {
  late Future<List<BookingSummary>> _bookingsFuture;
  final TextEditingController _commentController = TextEditingController();
  String? _selectedBookingId;
  int _rating = 5;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _loadUserBookings();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _bookingsFuture = _loadUserBookings();
    });
  }

  Future<List<BookingSummary>> _loadUserBookings() {
    final authVm = Get.find<AuthViewModel>();
    return BookingApi.getBookings(userId: authVm.currentUser.value?.userId);
  }

  Future<void> _submit() async {
    final bookingId = _selectedBookingId;
    if (bookingId == null || bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đặt phòng trước')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final feedback = await BookingApi.submitFeedback(
        SubmitFeedbackPayload(
          bookingId: bookingId,
          rating: _rating,
          comment: _commentController.text,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu đánh giá cho đặt phòng ${feedback.bookingId}'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FeedbackListPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gửi đánh giá thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gửi đánh giá'),
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

              final bookings = (snapshot.data ?? []).where((booking) {
                final status = booking.status.toUpperCase();
                return status == 'CHECKED_OUT' || status == 'COMPLETED';
              }).toList();
              final selectedExists = bookings.any(
                (booking) => booking.bookingId == _selectedBookingId,
              );

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  const _SubmitFeedbackHeader(),
                  const SizedBox(height: 18),
                  if (bookings.isEmpty)
                    const _EmptyHint(
                      icon: Icons.rate_review_outlined,
                      title: 'Chưa có đặt phòng đã hoàn tất',
                      message: 'Bạn có thể gửi đánh giá sau khi đã trả phòng.',
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: selectedExists ? _selectedBookingId : null,
                      decoration: const InputDecoration(
                        labelText: 'Đặt phòng đã hoàn tất',
                        border: OutlineInputBorder(),
                      ),
                      items: bookings
                          .map(
                            (booking) => DropdownMenuItem(
                              value: booking.bookingId,
                              child: Text(
                                '${booking.bookingId} - ${booking.guestName}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBookingId = value;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  _RatingSelector(
                    rating: _rating,
                    onChanged: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Bình luận',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _submitting || bookings.isEmpty ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: const Text('Gửi đánh giá & phản hồi'),
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

class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader({required this.totalFeedbacks});

  final int totalFeedbacks;

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
            'Đánh giá & phản hồi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Xem đánh giá và xếp hạng của khách cho các đặt phòng.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _Badge(label: '$totalFeedbacks đánh giá', color: Colors.orange),
        ],
      ),
    );
  }
}

class _SubmitFeedbackHeader extends StatelessWidget {
  const _SubmitFeedbackHeader();

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
            'Gửi đánh giá & phản hồi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn đặt phòng, chấm điểm và viết nhận xét ngắn.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final FeedbackModel feedback;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  feedback.guestName.isEmpty ? 'Khách' : feedback.guestName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StarRating(rating: feedback.rating),
            ],
          ),
          const SizedBox(height: 6),
          Text('Mã đặt phòng: ${feedback.bookingId}'),
          if (feedback.rooms.isNotEmpty)
            Text('Phòng: ${feedback.rooms.join(", ")}'),
          if (feedback.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(feedback.comment),
          ],
          const SizedBox(height: 10),
          _Badge(
            label: _bookingStatusText(feedback.bookingStatus),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

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
          Expanded(
            child: Text(
              'Xếp hạng',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          ...List.generate(5, (index) {
            final value = index + 1;
            return IconButton(
              onPressed: () => onChanged(value),
              icon: Icon(
                value <= rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: value <= rating ? Colors.amber.shade700 : scheme.outline,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        return Icon(
          value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber.shade700,
          size: 18,
        );
      }),
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
          'Bạn có chắc muốn gửi yêu cầu hủy đặt phòng ${booking.bookingId} không?',
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
      final message = BookingApi.errorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi yêu cầu hủy thất bại: $message')),
      );
    }
  }

  Future<void> _cancelCancelRequest(BookingSummary booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy yêu cầu hủy'),
        content: Text(
          'Bạn có chắc muốn hủy yêu cầu hủy đặt phòng ${booking.bookingId} không?',
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
        const SnackBar(content: Text('Đã hủy yêu cầu hủy đặt phòng')),
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
                          onRequestCancel: booking.canRequestCancel
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
            'Xem thông tin đặt phòng, cập nhật đơn hàng hoặc gửi yêu cầu hủy để lễ tân duyệt.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _Badge(label: '$totalBookings đặt phòng', color: Colors.orange),
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
          Text('Mã đặt phòng: ${booking.bookingId}'),
          Text('SĐT: ${booking.phone}'),
          Text(
            booking.rooms.isEmpty
                ? 'Phòng: Chưa có thông tin'
                : 'Phòng: ${booking.rooms.join(", ")}',
          ),
          Text('Ngày nhận phòng: ${booking.expectedCheckin}'),
          Text('Ngày trả phòng: ${booking.expectedCheckout}'),
          Text('Tổng tiền: ${booking.totalAmount ?? 0}'),
          const SizedBox(height: 8),
          _Badge(label: _statusText, color: _statusColor(context)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: actionCallback,
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
        title: const Text('Duyệt hủy đặt phòng'),
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
          Text('Mã đặt phòng: ${booking.bookingId}'),
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
        title: const Text('Nhận phòng / Trả phòng'),
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
                      child: Text('Không có đặt phòng nào theo ngày đã chọn'),
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
            'Nhận phòng / Trả phòng',
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
              _Badge(label: 'Đang chờ', color: schemeColor(context).tertiary),
              const SizedBox(width: 8),
              _Badge(
                label: 'Đã nhận phòng',
                color: schemeColor(context).primary,
              ),
              const SizedBox(width: 8),
              _Badge(label: 'Đã trả phòng', color: Colors.green),
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
                label: 'Còn trống',
                selected: selectedRoomStatus == 'AVAILABLE',
                onTap: () => onStatusChanged('AVAILABLE'),
              ),
              _StatusFilterChip(
                label: 'Đã đặt',
                selected: selectedRoomStatus == 'BOOKED',
                onTap: () => onStatusChanged('BOOKED'),
              ),
              _StatusFilterChip(
                label: 'Bảo trì',
                selected: selectedRoomStatus == 'MAINTENANCE',
                onTap: () => onStatusChanged('MAINTENANCE'),
              ),
              _StatusFilterChip(
                label: 'Tất cả',
                selected: selectedRoomStatus == 'ALL',
                onTap: () => onStatusChanged('ALL'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Badge(label: 'Còn trống', color: scheme.primary),
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
                Text('Trạng thái: ${_roomStatusText(room.status)}'),
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
          Text('Ngày nhận phòng: ${booking.expectedCheckin}'),
          Text('Ngày trả phòng: ${booking.expectedCheckout}'),
          Text('Tổng tiền: ${_formatMoney(_moneyValue(booking.totalAmount))}'),
          Text('Trạng thái: ${_bookingStatusText(booking.status)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onCheckIn != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onCheckIn,
                    child: const Text('Nhận phòng'),
                  ),
                ),
              if (onCheckIn != null && onCheckOut != null)
                const SizedBox(width: 8),
              if (onCheckOut != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onCheckOut,
                    child: const Text('Trả phòng'),
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
