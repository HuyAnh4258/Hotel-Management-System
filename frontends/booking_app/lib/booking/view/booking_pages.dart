import 'package:flutter/material.dart';

import '../viewmodel/booking_viewmodel.dart';

class RoomTypeDetailPage extends StatelessWidget {
  const RoomTypeDetailPage({
    super.key,
    required this.roomType,
    required this.availableRooms,
  });

  final RoomTypeModel roomType;
  final List<RoomModel> availableRooms;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(roomType.name),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.room_preferences_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          roomType.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    roomType.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.payments_rounded,
                          label: 'Giá từ',
                          value: roomType.basePrice.toStringAsFixed(0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.bed_rounded,
                          label: 'Phòng trống',
                          value: '${availableRooms.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chọn “Đặt loại phòng này” để xem danh sách phòng còn trống và tích chọn phòng phù hợp.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: availableRooms.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingFormPage(
                            roomType: roomType,
                            availableRooms: availableRooms,
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('Đặt loại phòng này'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({
    super.key,
    required this.roomType,
    required this.availableRooms,
  });

  final RoomTypeModel roomType;
  final List<RoomModel> availableRooms;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _checkinController = TextEditingController();
  final _checkoutController = TextEditingController();

  RoomModel? _selectedRoom;
  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableRooms.isNotEmpty) {
      _selectedRoom = widget.availableRooms.first;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _checkinController.dispose();
    _checkoutController.dispose();
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
        : (_checkoutDate ?? _checkinDate ?? now);
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
        if (_checkoutDate != null && _checkoutDate!.isBefore(picked)) {
          _checkoutDate = null;
          _checkoutController.clear();
        }
      } else {
        _checkoutDate = picked;
        _checkoutController.text = _formatDateForDisplay(picked);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedRoom == null ||
        _checkinDate == null ||
        _checkoutDate == null) {
      if (_selectedRoom == null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phòng')));
      }
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await BookingApi.createBooking(
        CreateBookingPayload(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          roomTypeId: widget.roomType.roomTypeId,
          roomId: _selectedRoom!.roomId,
          expectedCheckin: _formatDateForApi(_checkinDate!),
          expectedCheckout: _formatDateForApi(_checkoutDate!),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đặt phòng thành công')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đặt phòng thất bại: $e')));
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
        title: const Text('Booking form'),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          children: [
            Container(
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
                    'Đặt ${widget.roomType.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng điền thông tin, chọn ngày và tích chọn phòng để hoàn tất yêu cầu đặt phòng.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nhập số điện thoại'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _checkinController,
                    readOnly: true,
                    onTap: () => _pickDate(isCheckin: true),
                    decoration: const InputDecoration(
                      labelText: 'Ngày nhận phòng',
                      hintText: 'Chọn ngày nhận phòng',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                      suffixIcon: Icon(Icons.expand_more_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Chọn ngày nhận phòng'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _checkoutController,
                    readOnly: true,
                    onTap: () => _pickDate(isCheckin: false),
                    decoration: const InputDecoration(
                      labelText: 'Ngày trả phòng',
                      hintText: 'Chọn ngày trả phòng',
                      prefixIcon: Icon(Icons.event_rounded),
                      suffixIcon: Icon(Icons.expand_more_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Chọn ngày trả phòng'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _RoomSelectionList(
                    rooms: widget.availableRooms,
                    selectedRoom: _selectedRoom,
                    onSelected: (room) {
                      setState(() {
                        _selectedRoom = room;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(
                        _submitting ? 'Đang gửi...' : 'Xác nhận đặt phòng',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomSelectionList extends StatelessWidget {
  const _RoomSelectionList({
    required this.rooms,
    required this.selectedRoom,
    required this.onSelected,
  });

  final List<RoomModel> rooms;
  final RoomModel? selectedRoom;
  final ValueChanged<RoomModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn phòng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Tích chọn một phòng còn trống trong danh sách bên dưới.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          if (rooms.isEmpty)
            const Text('Không có phòng nào khả dụng')
          else
            ...rooms.map((room) {
              final isSelected = selectedRoom?.roomId == room.roomId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(room),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primary.withValues(alpha: 0.10)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? scheme.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? scheme.primary
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.hotel_rounded,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.roomNumber,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Tầng ${room.floor} • ${room.status}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
