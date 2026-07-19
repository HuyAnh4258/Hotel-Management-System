import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/core/widgets/app_widgets.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/voucher_viewmodel.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<VoucherViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Voucher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Làm mới',
            onPressed: vm.fetchVouchers,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Thêm voucher',
            onPressed: () => _showVoucherDialog(vm),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(vm),
          _buildSearchBar(vm),
          Expanded(child: _buildVoucherList(vm)),
        ],
      ),
    );
  }

  // ─── Summary ──────────────────────────────────────────────────

  Widget _buildSummary(VoucherViewModel vm) {
    return FadeTransition(
      opacity: _fade,
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Tổng voucher',
                  '${vm.totalVouchers}',
                  Icons.local_offer_outlined,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Đang hoạt động',
                  '${vm.activeCount}',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Đã hết hạn',
                  '${vm.expiredCount}',
                  Icons.timer_off_outlined,
                  AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────────

  Widget _buildSearchBar(VoucherViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Obx(
        () => TextField(
          controller: _searchCtrl,
          onChanged: vm.onSearchChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Tìm mã voucher...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: vm.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      vm.clearSearch();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  // ─── Voucher List ─────────────────────────────────────────────

  Widget _buildVoucherList(VoucherViewModel vm) {
    return Obx(() {
      if (vm.isLoading.value && vm.vouchers.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }

      if (vm.filteredVouchers.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: AppColors.accent,
        onRefresh: vm.fetchVouchers,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: vm.filteredVouchers.length,
          itemBuilder: (_, i) =>
              _buildVoucherCard(vm.filteredVouchers[i], vm),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 40,
              color: AppColors.textHint.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có voucher nào!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nhấn + để tạo voucher mới',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(VoucherItem voucher, VoucherViewModel vm) {
    final isExpired = voucher.isExpired;
    final statusColor = isExpired ? AppColors.danger : AppColors.success;
    final statusLabel = isExpired ? 'HẾT HẠN' : 'HIỆU LỰC';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        child: InkWell(
          onTap: () => _showVoucherActions(voucher, vm),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: statusColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        size: 24,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.voucherCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            voucher.discountSummary,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label: statusLabel, color: statusColor),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.border,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(
                      Icons.calendar_today_outlined,
                      'Hết hạn',
                      _formatDate(voucher.expiryTime),
                    ),
                    if (voucher.minBookingValue != null) ...[
                      const SizedBox(width: 16),
                      _infoChip(
                        Icons.price_check_outlined,
                        'Tối thiểu',
                        '${_fmtMoney(voucher.minBookingValue!)}đ',
                      ),
                    ],
                    if (voucher.maxDiscountAmount != null) ...[
                      const SizedBox(width: 16),
                      _infoChip(
                        Icons.money_off_outlined,
                        'Tối đa',
                        '${_fmtMoney(voucher.maxDiscountAmount!)}đ',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Action Bottom Sheet ───────────────────────────────────────

  void _showVoucherActions(VoucherItem voucher, VoucherViewModel vm) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        size: 28,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.voucherCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${voucher.discountSummary}  •  Hết hạn: ${_formatDate(voucher.expiryTime)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thao tác',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHint,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _actionRow(
                  Icons.edit_outlined,
                  'Chỉnh sửa voucher',
                  'Cập nhật mã, mức giảm giá hoặc ngày hết hạn',
                  AppColors.info,
                  () {
                    Get.back();
                    _showVoucherDialog(vm, existing: voucher);
                  },
                ),
                _actionRow(
                  Icons.delete_outline,
                  'Vô hiệu hóa',
                  'Ngừng sử dụng voucher này (không thể khôi phục)',
                  AppColors.danger,
                  () {
                    Get.back();
                    _confirmDeactivate(vm, voucher);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _actionRow(
    IconData icon,
    String label,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textHint,
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      ),
    );
  }

  // ─── Confirm Deactivate ───────────────────────────────────────

  void _confirmDeactivate(VoucherViewModel vm, VoucherItem voucher) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xác nhận vô hiệu hóa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn vô hiệu hóa voucher '),
              TextSpan(
                text: voucher.voucherCode,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(
                text: ' không?\n\nThao tác này ',
              ),
              const TextSpan(
                text: 'KHÔNG THỂ hoàn tác',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              const TextSpan(text: ' sau khi xác nhận.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              final err = await vm.deactivateVoucher(voucher.voucherId);
              if (err != null) {
                _showSnackError(err);
              } else {
                _showSnackSuccess('Đã vô hiệu hóa voucher ${voucher.voucherCode}');
              }
            },
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );
  }

  // ─── Create / Update Dialog ───────────────────────────────────

  void _showVoucherDialog(VoucherViewModel vm, {VoucherItem? existing}) {
    final isEdit = existing != null;
    final codeCtrl =
        TextEditingController(text: existing?.voucherCode ?? '');
    final pctCtrl = TextEditingController(
      text: existing?.discountPercent?.toStringAsFixed(
            existing.discountPercent! % 1 == 0 ? 0 : 2,
          ) ??
          '',
    );
    final maxCtrl = TextEditingController(
      text: existing?.maxDiscountAmount != null
          ? _fmtMoney(existing!.maxDiscountAmount!)
          : '',
    );
    final amtCtrl = TextEditingController(
      text: existing?.discountAmount != null
          ? _fmtMoney(existing!.discountAmount!)
          : '',
    );
    final minCtrl = TextEditingController(
      text: existing?.minBookingValue != null
          ? _fmtMoney(existing!.minBookingValue!)
          : '',
    );
    final expiryCtrl = TextEditingController(
      text: existing != null
          ? existing.expiryTime.substring(0, 10)
          : '',
    );
    DateTime? pickedDate = existing != null
        ? DateTime.tryParse(existing.expiryTime)
        : null;

    final formKey = GlobalKey<FormState>();
    vm.submitError.value = '';

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit
                                ? Icons.edit_outlined
                                : Icons.add_circle_outline,
                            color: AppColors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'Sửa Voucher' : 'Thêm Voucher Mới',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Voucher Code
                    TextFormField(
                      controller: codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Mã Voucher *',
                        hintText: 'VD: SUMMER2025, GIAM20...',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Mã voucher không được trống';
                        }
                        if (v.trim().length > 50) {
                          return 'Tối đa 50 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Discount Percent
                    TextFormField(
                      controller: pctCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d{0,2})?'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phần trăm giảm (%)',
                        hintText: 'VD: 10, 20.5...',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Giá trị không hợp lệ';
                        if (val <= 0) return 'Phải lớn hơn 0';
                        if (val > 100) return 'Không vượt quá 100%';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Max Discount Amount
                    TextFormField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Số tiền giảm tối đa (VNĐ)',
                        hintText: 'VD: 500.000',
                        prefixIcon: Icon(Icons.money_off_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final raw = v.replaceAll('.', '').trim();
                        if (double.tryParse(raw) == null) {
                          return 'Giá trị không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Discount Amount (fixed)
                    TextFormField(
                      controller: amtCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Số tiền giảm cố định (VNĐ)',
                        hintText: 'VD: 100.000 (nếu không dùng %)',
                        prefixIcon: Icon(Icons.local_atm_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final raw = v.replaceAll('.', '').trim();
                        if (double.tryParse(raw) == null) {
                          return 'Giá trị không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Min Booking Value
                    TextFormField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Giá trị đặt phòng tối thiểu (VNĐ)',
                        hintText: 'VD: 1.000.000',
                        prefixIcon: Icon(Icons.hotel_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final raw = v.replaceAll('.', '').trim();
                        if (double.tryParse(raw) == null) {
                          return 'Giá trị không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Expiry Date picker
                    TextFormField(
                      controller: expiryCtrl,
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: pickedDate != null &&
                                  pickedDate!.isAfter(now)
                              ? pickedDate!
                              : now.add(const Duration(days: 1)),
                          firstDate: now.add(const Duration(days: 1)),
                          lastDate: now.add(const Duration(days: 3650)),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: AppColors.surface,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          pickedDate = picked;
                          expiryCtrl.text =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Ngày hết hạn *',
                        hintText: 'Chọn ngày...',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng chọn ngày hết hạn';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'CHÚ Ý: Nhập ít nhất một trong hai trường: Phần trăm giảm HOẶC Số tiền giảm cố định.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),

                    // Error message
                    Obx(
                      () => vm.submitError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                vm.submitError.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => PrimaryButton(
                              label: isEdit ? 'Cập nhật' : 'Tạo Voucher',
                              icon: isEdit ? Icons.save_outlined : Icons.add,
                              isLoading: vm.isSubmitting.value,
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                // Additional validation: must have at least pct or amt
                                final pctRaw = pctCtrl.text.trim();
                                final amtRaw = amtCtrl.text
                                    .replaceAll('.', '')
                                    .trim();
                                if (pctRaw.isEmpty && amtRaw.isEmpty) {
                                  vm.submitError.value =
                                      'Vui lòng nhập Phần trăm giảm hoặc Số tiền giảm cố định';
                                  return;
                                }

                                final code = codeCtrl.text.trim().toUpperCase();
                                final pct = pctRaw.isEmpty
                                    ? null
                                    : double.tryParse(pctRaw);
                                final maxAmt = maxCtrl.text
                                        .replaceAll('.', '')
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : double.tryParse(
                                        maxCtrl.text.replaceAll('.', '').trim(),
                                      );
                                final amt = amtRaw.isEmpty
                                    ? null
                                    : double.tryParse(amtRaw);
                                final minVal = minCtrl.text
                                        .replaceAll('.', '')
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : double.tryParse(
                                        minCtrl.text.replaceAll('.', '').trim(),
                                      );

                                // Build ISO datetime with end-of-day time
                                final expiry = pickedDate != null
                                    ? '${expiryCtrl.text}T23:59:59'
                                    : '';

                                String? error;
                                if (isEdit) {
                                  error = await vm.updateVoucher(
                                    id: existing!.voucherId,
                                    voucherCode: code,
                                    discountPercent: pct,
                                    maxDiscountAmount: maxAmt,
                                    discountAmount: amt,
                                    minBookingValue: minVal,
                                    expiryTime: expiry,
                                  );
                                } else {
                                  error = await vm.createVoucher(
                                    voucherCode: code,
                                    discountPercent: pct,
                                    maxDiscountAmount: maxAmt,
                                    discountAmount: amt,
                                    minBookingValue: minVal,
                                    expiryTime: expiry,
                                  );
                                }

                                if (error == null) {
                                  Get.back();
                                  _showSnackSuccess(
                                    isEdit
                                        ? 'Đã cập nhật voucher $code'
                                        : 'Đã tạo voucher $code thành công',
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _fmtMoney(double v) {
    final parts = v.toStringAsFixed(0).split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  void _showSnackSuccess(String msg) {
    Get.snackbar(
      'Thành công',
      msg,
      backgroundColor: AppColors.success.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  void _showSnackError(String msg) {
    Get.snackbar(
      'Lỗi',
      msg,
      backgroundColor: AppColors.danger.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }
}

// ─── Thousands Formatter ──────────────────────────────────────────────────────

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final raw = newValue.text.replaceAll('.', '');
    if (raw.isEmpty) return newValue;
    final number = int.tryParse(raw);
    if (number == null) return oldValue;

    final parts = raw.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
