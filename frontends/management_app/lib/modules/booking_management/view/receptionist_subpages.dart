import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ServiceOrderStatusPage extends StatefulWidget {
  const ServiceOrderStatusPage({super.key, required this.canUpdate});

  final bool canUpdate;

  @override
  State<ServiceOrderStatusPage> createState() => _ServiceOrderStatusPageState();
}

class _ServiceOrderStatusPageState extends State<ServiceOrderStatusPage> {
  late Future<List<ServiceOrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = BookingApi.getServiceOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _ordersFuture = BookingApi.getServiceOrders();
    });
  }

  Future<void> _update(ServiceOrderModel order, String status) async {
    await BookingApi.updateServiceOrderStatus(order.orderId, status);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ${order.orderId} to $status')),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = widget.canUpdate
        ? 'Update Order Status'
        : 'View Order Status';

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
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<ServiceOrderModel>>(
            future: _ordersFuture,
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

              final orders = snapshot.data ?? [];
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _ServiceOrderHeader(
                    title: title,
                    subtitle: widget.canUpdate
                        ? 'Receptionist updates service order progress.'
                        : 'Receptionist views all service order statuses.',
                    totalOrders: orders.length,
                  ),
                  const SizedBox(height: 18),
                  if (orders.isEmpty)
                    const Text('No service orders yet')
                  else
                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceOrderCard(
                          order: order,
                          canUpdate: widget.canUpdate,
                          onUpdate: (status) => _update(order, status),
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

class ExportInvoicePage extends StatelessWidget {
  const ExportInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServiceOrderWorkflowPage(
      mode: _ServiceOrderWorkflowMode.invoice,
    );
  }
}

class OrderRequestsPage extends StatelessWidget {
  const OrderRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServiceOrderWorkflowPage(
      mode: _ServiceOrderWorkflowMode.requests,
    );
  }
}

class ProcessOrderPage extends StatelessWidget {
  const ProcessOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServiceOrderWorkflowPage(
      mode: _ServiceOrderWorkflowMode.process,
    );
  }
}

enum _ServiceOrderWorkflowMode { invoice, requests, process }

class _ServiceOrderWorkflowPage extends StatefulWidget {
  const _ServiceOrderWorkflowPage({required this.mode});

  final _ServiceOrderWorkflowMode mode;

  @override
  State<_ServiceOrderWorkflowPage> createState() =>
      _ServiceOrderWorkflowPageState();
}

class _ServiceOrderWorkflowPageState extends State<_ServiceOrderWorkflowPage> {
  late Future<List<ServiceOrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = BookingApi.getServiceOrders();
  }

  Future<void> _reload() async {
    setState(() {
      _ordersFuture = BookingApi.getServiceOrders();
    });
  }

  Future<void> _update(ServiceOrderModel order, String status) async {
    await BookingApi.updateServiceOrderStatus(order.orderId, status);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ${order.orderId} to $status')),
    );
    await _reload();
  }

  Future<void> _copyInvoice(ServiceOrderModel order) async {
    await Clipboard.setData(ClipboardData(text: _buildInvoiceText(order)));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice copied for ${order.orderId}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = _workflowTitle(widget.mode);

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
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<ServiceOrderModel>>(
            future: _ordersFuture,
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

              final orders = (snapshot.data ?? [])
                  .where((order) => _matchesWorkflow(widget.mode, order))
                  .toList();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  _ServiceOrderHeader(
                    title: title,
                    subtitle: _workflowSubtitle(widget.mode),
                    totalOrders: orders.length,
                  ),
                  const SizedBox(height: 18),
                  if (orders.isEmpty)
                    Text(_workflowEmptyText(widget.mode))
                  else
                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWorkflowCard(order),
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

  Widget _buildWorkflowCard(ServiceOrderModel order) {
    switch (widget.mode) {
      case _ServiceOrderWorkflowMode.invoice:
        return _InvoiceOrderCard(
          order: order,
          onCopy: () => _copyInvoice(order),
        );
      case _ServiceOrderWorkflowMode.requests:
        return _RequestOrderCard(order: order);
      case _ServiceOrderWorkflowMode.process:
        return _ProcessOrderCard(
          order: order,
          onStart: order.status.toUpperCase() == 'PENDING'
              ? () => _update(order, 'IN_PROGRESS')
              : null,
          onComplete: order.status.toUpperCase() == 'IN_PROGRESS'
              ? () => _update(order, 'COMPLETED')
              : null,
        );
    }
  }
}

class _RequestOrderCard extends StatelessWidget {
  const _RequestOrderCard({required this.order});

  final ServiceOrderModel order;

  @override
  Widget build(BuildContext context) {
    return _OrderInfoCard(
      order: order,
      footer: const Text(
        'Waiting for receptionist to process this request.',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProcessOrderCard extends StatelessWidget {
  const _ProcessOrderCard({
    required this.order,
    required this.onStart,
    required this.onComplete,
  });

  final ServiceOrderModel order;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return _OrderInfoCard(
      order: order,
      footer: Row(
        children: [
          if (onStart != null)
            Expanded(
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Process'),
              ),
            ),
          if (onStart != null && onComplete != null) const SizedBox(width: 8),
          if (onComplete != null)
            Expanded(
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Complete Order'),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceOrderCard extends StatelessWidget {
  const _InvoiceOrderCard({required this.order, required this.onCopy});

  final ServiceOrderModel order;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _OrderInfoCard(
      order: order,
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy Invoice'),
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order, required this.footer});

  final ServiceOrderModel order;
  final Widget footer;

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
                label: order.status,
                color: _serviceOrderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Order: ${order.orderId}'),
          Text('Booking: ${order.bookingId}'),
          Text('Phone: ${order.phone}'),
          Text('Ordered at: ${order.orderedAt}'),
          const SizedBox(height: 8),
          if (order.services.isEmpty)
            const Text('No services in this order')
          else
            ...order.services.map(
              (line) => Text(
                '${line.serviceName} x${line.quantity} - ${_formatMoney(line.lineTotal)}',
              ),
            ),
          const Divider(height: 20),
          Text(
            'Total: ${_formatMoney(order.totalAmount)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }
}

String _workflowTitle(_ServiceOrderWorkflowMode mode) {
  switch (mode) {
    case _ServiceOrderWorkflowMode.invoice:
      return 'Export Invoice';
    case _ServiceOrderWorkflowMode.requests:
      return 'View Order Requests';
    case _ServiceOrderWorkflowMode.process:
      return 'Process Order';
  }
}

String _workflowSubtitle(_ServiceOrderWorkflowMode mode) {
  switch (mode) {
    case _ServiceOrderWorkflowMode.invoice:
      return 'Receptionist exports invoices for completed service orders.';
    case _ServiceOrderWorkflowMode.requests:
      return 'Receptionist views service orders waiting for processing.';
    case _ServiceOrderWorkflowMode.process:
      return 'Receptionist starts pending orders and completes in-progress orders.';
  }
}

String _workflowEmptyText(_ServiceOrderWorkflowMode mode) {
  switch (mode) {
    case _ServiceOrderWorkflowMode.invoice:
      return 'No completed orders to export invoice yet';
    case _ServiceOrderWorkflowMode.requests:
      return 'No pending order requests';
    case _ServiceOrderWorkflowMode.process:
      return 'No orders waiting for processing';
  }
}

bool _matchesWorkflow(_ServiceOrderWorkflowMode mode, ServiceOrderModel order) {
  final status = order.status.toUpperCase();
  switch (mode) {
    case _ServiceOrderWorkflowMode.invoice:
      return status == 'COMPLETED';
    case _ServiceOrderWorkflowMode.requests:
      return status == 'PENDING';
    case _ServiceOrderWorkflowMode.process:
      return status == 'PENDING' || status == 'IN_PROGRESS';
  }
}

String _buildInvoiceText(ServiceOrderModel order) {
  final buffer = StringBuffer()
    ..writeln('FPT Golden Hotel')
    ..writeln('SERVICE ORDER INVOICE')
    ..writeln('Order: ${order.orderId}')
    ..writeln('Booking: ${order.bookingId}')
    ..writeln('Guest: ${order.guestName.isEmpty ? 'N/A' : order.guestName}')
    ..writeln('Phone: ${order.phone.isEmpty ? 'N/A' : order.phone}')
    ..writeln('Ordered at: ${order.orderedAt}')
    ..writeln('Status: ${order.status}')
    ..writeln('')
    ..writeln('Services:');

  if (order.services.isEmpty) {
    buffer.writeln('- No service lines');
  } else {
    for (final line in order.services) {
      buffer.writeln(
        '- ${line.serviceName} x${line.quantity}: '
        '${_formatMoney(line.lineTotal)}',
      );
    }
  }

  buffer
    ..writeln('')
    ..writeln('Total: ${_formatMoney(order.totalAmount)}');

  return buffer.toString();
}

class _ServiceOrderHeader extends StatelessWidget {
  const _ServiceOrderHeader({
    required this.title,
    required this.subtitle,
    required this.totalOrders,
  });

  final String title;
  final String subtitle;
  final int totalOrders;

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
          _Badge(label: '$totalOrders orders', color: Colors.orange),
        ],
      ),
    );
  }
}

class _ServiceOrderCard extends StatelessWidget {
  const _ServiceOrderCard({
    required this.order,
    required this.canUpdate,
    required this.onUpdate,
  });

  final ServiceOrderModel order;
  final bool canUpdate;
  final ValueChanged<String> onUpdate;

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
                label: order.status,
                color: _serviceOrderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Order: ${order.orderId}'),
          Text('Booking: ${order.bookingId}'),
          Text('Phone: ${order.phone}'),
          Text('Ordered at: ${order.orderedAt}'),
          Text('Total: ${_formatMoney(order.totalAmount)}'),
          if (order.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...order.services.map(
              (line) => Text(
                '${line.serviceName} x${line.quantity} - ${_formatMoney(line.lineTotal)}',
              ),
            ),
          ],
          if (canUpdate) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  const [
                    'PENDING',
                    'IN_PROGRESS',
                    'COMPLETED',
                    'CANCELLED',
                  ].map((status) {
                    final selected = order.status.toUpperCase() == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: selected ? null : (_) => onUpdate(status),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

Color _serviceOrderStatusColor(String status) {
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

String _formatMoney(num value) => '${value.toStringAsFixed(0)} VND';

num _moneyValue(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
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
          Text(
            'Total payment: ${_formatMoney(_moneyValue(booking.totalAmount))}',
          ),
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
