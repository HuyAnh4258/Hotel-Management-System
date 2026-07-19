import 'package:get/get.dart';
import 'package:hms_shared/constants/api_constants.dart';
import 'package:hms_shared/network/dio_client.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class VoucherItem {
  final String voucherId;
  final String voucherCode;
  final double? discountPercent;
  final double? maxDiscountAmount;
  final double? discountAmount;
  final double? minBookingValue;
  final String expiryTime;
  final bool isActive;
  final String? createdAt;

  VoucherItem({
    required this.voucherId,
    required this.voucherCode,
    this.discountPercent,
    this.maxDiscountAmount,
    this.discountAmount,
    this.minBookingValue,
    required this.expiryTime,
    required this.isActive,
    this.createdAt,
  });

  bool get isExpired {
    try {
      return DateTime.parse(expiryTime).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String get discountSummary {
    if (discountPercent != null && discountPercent! > 0) {
      final pct = discountPercent!.toStringAsFixed(
        discountPercent! % 1 == 0 ? 0 : 1,
      );
      return 'Giảm $pct%';
    }
    if (discountAmount != null && discountAmount! > 0) {
      return 'Giảm ${_fmtMoney(discountAmount!)}đ';
    }
    return 'Không xác định';
  }

  static String _fmtMoney(double v) {
    final parts = v.toStringAsFixed(0).split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  factory VoucherItem.fromJson(Map<String, dynamic> json) => VoucherItem(
        voucherId: json['voucherId'] as String? ?? '',
        voucherCode: json['voucherCode'] as String? ?? '',
        discountPercent: (json['discountPercent'] as num?)?.toDouble(),
        maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        minBookingValue: (json['minBookingValue'] as num?)?.toDouble(),
        expiryTime: json['expiryTime'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] as String?,
      );
}

// ─── ViewModel ───────────────────────────────────────────────────────────────

class VoucherViewModel extends GetxController {
  final DioClient _dioClient;

  final RxList<VoucherItem> _vouchers = <VoucherItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;
  final RxString searchQuery = ''.obs;

  VoucherViewModel(this._dioClient);

  List<VoucherItem> get filteredVouchers {
    if (searchQuery.value.isEmpty) return _vouchers;
    final q = searchQuery.value.toLowerCase();
    return _vouchers
        .where((v) => v.voucherCode.toLowerCase().contains(q))
        .toList();
  }

  List<VoucherItem> get vouchers => _vouchers;

  int get totalVouchers => _vouchers.length;
  int get activeCount => _vouchers.where((v) => v.isActive).length;
  int get expiredCount => _vouchers.where((v) => v.isExpired).length;

  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
  }

  // ─── FETCH ─────────────────────────────────────────────────────

  Future<void> fetchVouchers() async {
    isLoading.value = true;
    try {
      final response = await _dioClient.dio.get(ApiConstants.vouchers);
      _vouchers.value = (response.data as List)
          .map((e) => VoucherItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // ─── CREATE ─────────────────────────────────────────────────────

  Future<String?> createVoucher({
    required String voucherCode,
    double? discountPercent,
    double? maxDiscountAmount,
    double? discountAmount,
    double? minBookingValue,
    required String expiryTime,
  }) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dioClient.dio.post(
        ApiConstants.vouchers,
        data: {
          'voucherCode': voucherCode,
          if (discountPercent != null) 'discountPercent': discountPercent,
          if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
          if (discountAmount != null) 'discountAmount': discountAmount,
          if (minBookingValue != null) 'minBookingValue': minBookingValue,
          'expiryTime': expiryTime,
        },
      );
      await fetchVouchers();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── UPDATE ─────────────────────────────────────────────────────

  Future<String?> updateVoucher({
    required String id,
    required String voucherCode,
    double? discountPercent,
    double? maxDiscountAmount,
    double? discountAmount,
    double? minBookingValue,
    required String expiryTime,
  }) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dioClient.dio.put(
        ApiConstants.voucherById(id),
        data: {
          'voucherCode': voucherCode,
          if (discountPercent != null) 'discountPercent': discountPercent,
          if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
          if (discountAmount != null) 'discountAmount': discountAmount,
          if (minBookingValue != null) 'minBookingValue': minBookingValue,
          'expiryTime': expiryTime,
        },
      );
      await fetchVouchers();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── SOFT DELETE ────────────────────────────────────────────────

  Future<String?> deactivateVoucher(String id) async {
    try {
      await _dioClient.dio.patch(ApiConstants.voucherDeactivate(id));
      await fetchVouchers();
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  // ─── SEARCH ─────────────────────────────────────────────────────

  void onSearchChanged(String value) => searchQuery.value = value;
  void clearSearch() => searchQuery.value = '';

  // ─── PRIVATE ────────────────────────────────────────────────────

  String _extractError(dynamic e) {
    try {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
    } catch (_) {}
    final s = e.toString();
    if (s.contains('RuntimeException:')) {
      return s.split('RuntimeException:').last.trim();
    }
    return 'Có lỗi xảy ra, vui lòng thử lại';
  }
}
