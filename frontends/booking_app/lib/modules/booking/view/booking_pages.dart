import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/booking_viewmodel.dart';

class RoomTypeDetailPage extends StatelessWidget {
  const RoomTypeDetailPage({
    super.key,
    required this.roomType,
    required this.availableRooms,
    this.onViewFeedback,
    this.onSubmitFeedback,
    this.initialCheckin,
    this.initialCheckout,
    this.initialGuestCount,
  });

  final RoomTypeModel roomType;
  final List<RoomModel> availableRooms;
  final VoidCallback? onViewFeedback;
  final VoidCallback? onSubmitFeedback;
  final DateTime? initialCheckin;
  final DateTime? initialCheckout;
  final int? initialGuestCount;

  String _formatPrice(double price) => price.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final galleryImages = _roomGalleryImages(roomType, availableRooms);

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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _RoomImage(
                          source: roomType.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            roomType.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                                value: '${_formatPrice(roomType.basePrice)} đ',
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
                        const SizedBox(height: 12),
                        _DetailInfoRow(
                          label: 'Mã loại phòng',
                          value: roomType.roomTypeId.isEmpty
                              ? 'Chưa có'
                              : roomType.roomTypeId,
                        ),
                        const SizedBox(height: 8),
                        _DetailInfoRow(
                          label: 'Mô tả',
                          value: roomType.description,
                        ),
                        if (galleryImages.length > 1) ...[
                          const SizedBox(height: 16),
                          _RoomPhotoGallery(images: galleryImages),
                        ],
                      ],
                    ),
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
                      'Chọn “Đặt loại phòng này” để xem danh sách phòng còn trống và chọn phòng phù hợp.',
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
            if (onViewFeedback != null || onSubmitFeedback != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá & phản hồi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Xem đánh giá trước khi đặt phòng hoặc gửi phản hồi sau khi trải nghiệm.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (onViewFeedback != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onViewFeedback,
                          icon: const Icon(Icons.reviews_rounded),
                          label: const Text('Xem đánh giá & phản hồi'),
                        ),
                      ),
                    if (onViewFeedback != null && onSubmitFeedback != null)
                      const SizedBox(height: 10),
                    if (onSubmitFeedback != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onSubmitFeedback,
                          icon: const Icon(Icons.rate_review_rounded),
                          label: const Text('Gửi đánh giá & phản hồi'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            FilledButton.icon(
              onPressed: availableRooms.isEmpty
                  ? null
                  : () async {
                      final authVm = Get.find<AuthViewModel>();
                      if (!authVm.isLoggedIn) {
                        final loggedIn = await Get.toNamed('/login');
                        if (!context.mounted) return;
                        if (loggedIn != true && !authVm.isLoggedIn) {
                          return;
                        }
                      }

                      final booked = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BookingFormPage(
                            roomType: roomType,
                            availableRooms: availableRooms,
                            initialCheckin: initialCheckin,
                            initialCheckout: initialCheckout,
                            initialGuestCount: initialGuestCount,
                          ),
                        ),
                      );

                      if (booked == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
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

List<String> _roomGalleryImages(
  RoomTypeModel roomType,
  List<RoomModel> availableRooms,
) {
  final images = <String>[];
  final seen = <String>{};

  void addImage(String? source) {
    final normalized = source?.trim();
    if (normalized == null || normalized.isEmpty || seen.contains(normalized)) {
      return;
    }
    seen.add(normalized);
    images.add(normalized);
  }

  addImage(roomType.imagePath);
  for (final room in availableRooms) {
    addImage(room.imagePath);
  }

  const fallbackImages = [
    'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=900&q=80',
    'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=900&q=80',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=900&q=80',
  ];
  for (final image in fallbackImages) {
    if (images.length >= 3) break;
    addImage(image);
  }

  return images;
}

class _RoomPhotoGallery extends StatelessWidget {
  const _RoomPhotoGallery({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh phòng',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 136,
                  height: 92,
                  child: _RoomImage(source: images[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RoomImage extends StatelessWidget {
  const _RoomImage({required this.source, required this.fit});

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = source.trim();
    final placeholder = Container(
      color: scheme.primary.withValues(alpha: 0.10),
      child: Icon(Icons.hotel_rounded, size: 56, color: scheme.primary),
    );

    if (normalized.isEmpty) {
      return placeholder;
    }

    final isNetwork =
        normalized.startsWith('http://') || normalized.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        normalized,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return Image.asset(
      normalized,
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
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

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade800,
              height: 1.45,
            ),
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
    this.prefillBooking,
    this.lockDates = false,
    this.initialCheckin,
    this.initialCheckout,
    this.initialGuestName,
    this.initialPhone,
    this.initialEmail,
    this.initialSelectedRoomId,
    this.initialGuestCount,
    this.changeBookingId,
    this.onBookingChanged,
    this.dialogMode = false,
  });

  final RoomTypeModel roomType;
  final List<RoomModel> availableRooms;
  final BookingSummary? prefillBooking;
  final bool lockDates;
  final DateTime? initialCheckin;
  final DateTime? initialCheckout;
  final String? initialGuestName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialSelectedRoomId;
  final int? initialGuestCount;
  final String? changeBookingId;
  final ValueChanged<BookingSummary>? onBookingChanged;
  final bool dialogMode;

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
  final _guestCountController = TextEditingController();

  RoomModel? _selectedRoom;
  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  List<RoomModel> _availableRooms = [];
  bool _loadingRooms = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _availableRooms = List<RoomModel>.from(widget.availableRooms);

    if (widget.changeBookingId != null) {
      _loadChangeableRooms();
    }

    final booking = widget.prefillBooking;
    final authVm = Get.find<AuthViewModel>();
    final currentUser = authVm.currentUser.value;

    _fullNameController.text =
        widget.initialGuestName ??
        booking?.guestName ??
        currentUser?.fullName ??
        '';
    _phoneController.text =
        widget.initialPhone ?? booking?.phone ?? currentUser?.phone ?? '';
    _emailController.text =
        widget.initialEmail ?? booking?.email ?? currentUser?.email ?? '';
    _guestCountController.text = (widget.initialGuestCount ?? 1).toString();

    final parsedCheckin =
        widget.initialCheckin ??
        DateTime.tryParse(booking?.expectedCheckin ?? '');
    final parsedCheckout =
        widget.initialCheckout ??
        DateTime.tryParse(booking?.expectedCheckout ?? '');

    if (parsedCheckin != null) {
      _checkinDate = parsedCheckin;
      _checkinController.text = _formatDateForDisplay(parsedCheckin);
    }

    if (parsedCheckout != null) {
      _checkoutDate = parsedCheckout;
      _checkoutController.text = _formatDateForDisplay(parsedCheckout);
    }

    if (widget.initialSelectedRoomId != null) {
      _selectedRoom = _availableRooms.isNotEmpty
          ? _availableRooms.firstWhere(
              (room) => room.roomId == widget.initialSelectedRoomId,
              orElse: () => _availableRooms.first,
            )
          : null;
    } else if (widget.changeBookingId != null &&
        widget.prefillBooking != null) {
      final currentRoomId = widget.prefillBooking!.rooms.isNotEmpty
          ? widget.prefillBooking!.rooms.first
          : null;
      if (currentRoomId != null) {
        _selectedRoom = _availableRooms.firstWhere(
          (room) => room.roomId == currentRoomId,
          orElse: () => _availableRooms.first,
        );
      }
    } else if (_availableRooms.isNotEmpty) {
      _selectedRoom = _availableRooms.first;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _checkinController.dispose();
    _checkoutController.dispose();
    _guestCountController.dispose();
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

  int? _calculateNights() {
    if (_checkinDate == null || _checkoutDate == null) return null;
    return _checkoutDate!.difference(_checkinDate!).inDays;
  }

  double _dailyRate() => widget.roomType.basePrice;

  double? _calculateTotalAmount() {
    final nights = _calculateNights();
    if (nights == null || nights <= 0) return null;
    return nights * _dailyRate();
  }

  Future<void> _loadChangeableRooms() async {
    final bookingId = widget.changeBookingId;
    if (bookingId == null) return;

    setState(() {
      _loadingRooms = true;
    });

    try {
      final rooms = await BookingApi.getChangeableRooms(bookingId);
      if (!mounted) return;

      setState(() {
        _availableRooms = rooms
            .where((room) => room.roomTypeId == widget.roomType.roomTypeId)
            .toList();

        if (widget.prefillBooking != null && _availableRooms.isNotEmpty) {
          final currentRoomId = widget.prefillBooking!.rooms.isNotEmpty
              ? widget.prefillBooking!.rooms.first
              : null;

          if (currentRoomId != null) {
            _selectedRoom = _availableRooms.firstWhere(
              (room) => room.roomId == currentRoomId,
              orElse: () => _availableRooms.first,
            );
          }
        }

        if (_selectedRoom == null && _availableRooms.isNotEmpty) {
          _selectedRoom = _availableRooms.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được danh sách phòng đổi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingRooms = false;
        });
      }
    }
  }

  Future<void> _reloadAvailableRooms() async {
    if (_checkinDate == null || _checkoutDate == null) return;

    setState(() {
      _loadingRooms = true;
    });

    try {
      final rooms = await BookingApi.getAvailableRooms(
        checkin: _formatDateForApi(_checkinDate!),
        checkout: _formatDateForApi(_checkoutDate!),
      );

      if (!mounted) return;
      final filteredRooms = rooms
          .where((room) => room.roomTypeId == widget.roomType.roomTypeId)
          .toList();

      setState(() {
        _availableRooms = filteredRooms;
        if (_selectedRoom != null &&
            !_availableRooms.any(
              (room) => room.roomId == _selectedRoom!.roomId,
            )) {
          _selectedRoom = _availableRooms.isNotEmpty
              ? _availableRooms.first
              : null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không tải được phòng trống: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loadingRooms = false;
        });
      }
    }
  }

  Future<void> _pickDate({required bool isCheckin}) async {
    if (widget.lockDates || widget.changeBookingId != null) return;

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

    if (_checkinDate != null && _checkoutDate != null) {
      await _reloadAvailableRooms();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedRoom == null ||
        (_checkinDate == null && widget.initialCheckin == null) ||
        (_checkoutDate == null && widget.initialCheckout == null)) {
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
      BookingSummary? result;
      if (widget.changeBookingId != null) {
        result = await BookingApi.changeBookingRoom(
          widget.changeBookingId!,
          _selectedRoom!.roomId,
        );
      } else {
        final authVm = Get.find<AuthViewModel>();
        await BookingApi.createBooking(
          CreateBookingPayload(
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            userId: authVm.currentUser.value?.userId ?? '',
            roomTypeId: widget.roomType.roomTypeId,
            roomId: _selectedRoom!.roomId,
            expectedCheckin: _formatDateForApi(_checkinDate!),
            expectedCheckout: _formatDateForApi(_checkoutDate!),
          ),
        );
      }

      if (!mounted) return;

      if (result != null) {
        widget.onBookingChanged?.call(result);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.changeBookingId != null
                ? 'Đổi phòng thành công'
                : 'Đặt phòng thành công, trạng thái đang chờ',
          ),
        ),
      );

      if (widget.dialogMode) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.changeBookingId != null
                ? 'Đổi phòng thất bại: $e'
                : 'Đặt phòng thất bại: $e',
          ),
        ),
      );
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
        title: const Text('Đặt phòng'),
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
                  Text(
                    widget.changeBookingId != null
                        ? 'Thay đổi đơn hàng'
                        : 'Đặt ${widget.roomType.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.changeBookingId != null
                        ? 'Chọn 1 phòng còn trống cùng loại phòng. Ngày nhận và trả phòng được giữ nguyên.'
                        : 'Vui lòng điền thông tin, chọn ngày và tích chọn phòng để hoàn tất yêu cầu đặt phòng.',
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
                    readOnly: true,
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
                    readOnly: true,
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
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _checkinController,
                    readOnly: true,
                    enabled:
                        !widget.lockDates && widget.changeBookingId == null,
                    onTap: () => _pickDate(isCheckin: true),
                    decoration: InputDecoration(
                      labelText: 'Ngày nhận phòng',
                      hintText: 'Chọn ngày nhận phòng',
                      prefixIcon: const Icon(Icons.calendar_month_rounded),
                      suffixIcon: widget.changeBookingId != null
                          ? const Icon(Icons.lock_rounded)
                          : const Icon(Icons.expand_more_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Chọn ngày nhận phòng'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _checkoutController,
                    readOnly: true,
                    enabled:
                        !widget.lockDates && widget.changeBookingId == null,
                    onTap: () => _pickDate(isCheckin: false),
                    decoration: InputDecoration(
                      labelText: 'Ngày trả phòng',
                      hintText: 'Chọn ngày trả phòng',
                      prefixIcon: const Icon(Icons.event_rounded),
                      suffixIcon: widget.changeBookingId != null
                          ? const Icon(Icons.lock_rounded)
                          : const Icon(Icons.expand_more_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Chọn ngày trả phòng'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _guestCountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Số khách',
                      prefixIcon: Icon(Icons.group_rounded),
                    ),
                    validator: (value) {
                      final guests = int.tryParse(value?.trim() ?? '');
                      if (guests == null || guests <= 0) {
                        return 'Nhập số khách hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _RoomSelectionList(
                    rooms: _availableRooms,
                    selectedRoom: _selectedRoom,
                    onSelected: (room) {
                      setState(() {
                        _selectedRoom = room;
                      });
                    },
                    loading: _loadingRooms,
                    lockedRoomId: widget.changeBookingId != null
                        ? null
                        : widget.initialSelectedRoomId,
                    headerTitle: widget.changeBookingId != null
                        ? 'Chọn phòng mới'
                        : null,
                    headerSubtitle: widget.changeBookingId != null
                        ? 'Chỉ chọn 1 phòng còn trống cùng loại phòng.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _BookingCostSummaryCard(
                    nights: _calculateNights(),
                    dailyRate: _dailyRate(),
                    totalAmount: _calculateTotalAmount() ?? 0,
                    guestCount:
                        int.tryParse(_guestCountController.text.trim()) ?? 0,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Hủy và quay lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: Text(
                            _submitting
                                ? 'Đang gửi...'
                                : widget.changeBookingId != null
                                ? 'Xác nhận'
                                : 'Xác nhận đặt phòng',
                          ),
                        ),
                      ),
                    ],
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

class _BookingCostSummaryCard extends StatelessWidget {
  const _BookingCostSummaryCard({
    required this.nights,
    required this.dailyRate,
    required this.totalAmount,
    required this.guestCount,
  });

  final int? nights;
  final double dailyRate;
  final double totalAmount;
  final int guestCount;

  String _formatMoney(double value) => value.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            'Tóm tắt đặt phòng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Số khách', value: '$guestCount khách'),
          _SummaryLine(
            label: 'Giá mỗi đêm',
            value: '${_formatMoney(dailyRate)} VND',
          ),
          const SizedBox(height: 8),
          Text(
            (nights == null || nights! <= 0)
                ? 'Chọn ngày nhận/trả phòng hợp lệ để tính tiền.'
                : '${nights!} đêm × ${_formatMoney(dailyRate)} đ = ${_formatMoney(totalAmount)} đ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          if (nights != null && nights! > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Giá loại phòng tính theo 1 ngày. Tổng tiền = số đêm × đơn giá.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

class _RoomSelectionList extends StatelessWidget {
  const _RoomSelectionList({
    required this.rooms,
    required this.selectedRoom,
    required this.onSelected,
    required this.loading,
    this.lockedRoomId,
    this.headerTitle,
    this.headerSubtitle,
  });

  final List<RoomModel> rooms;
  final RoomModel? selectedRoom;
  final ValueChanged<RoomModel> onSelected;
  final bool loading;
  final String? lockedRoomId;
  final String? headerTitle;
  final String? headerSubtitle;

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
            headerTitle ?? 'Chọn phòng',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            headerSubtitle ??
                'Tích chọn một phòng còn trống trong danh sách bên dưới.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rooms.isEmpty)
            const Text('Không có phòng nào khả dụng')
          else
            ...rooms.map((room) {
              final isSelected = selectedRoom?.roomId == room.roomId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: lockedRoomId != null && lockedRoomId != room.roomId
                      ? null
                      : () => onSelected(room),
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
                                'Tầng ${room.floor} • ${room.status.toUpperCase()}',
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
