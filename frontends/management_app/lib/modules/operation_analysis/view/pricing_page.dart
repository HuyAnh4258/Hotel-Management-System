import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/operation_analysis/viewmodel/service_viewmodel.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});
  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _invSearch = TextEditingController();
  final _svcSearch = TextEditingController();
  String _invSortBy = 'name';
  bool _invAsc = true;
  String _svcSortBy = 'name';
  bool _svcAsc = true;

  @override
  void dispose() {
    _invSearch.dispose();
    _svcSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<InventoryViewModel>();
    final svm = Get.find<ServiceViewModel>();
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đặt & Điều chỉnh giá')),
      body: isWide ? _wide(vm, svm) : _narrow(vm, svm),
    );
  }

  Widget _wide(i, s) => Row(
    children: [
      Expanded(child: _invCol(i)),
      Container(width: 1, color: AppColors.border),
      Expanded(child: _svcCol(s)),
    ],
  );
  Widget _narrow(i, s) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const TabBar(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Vật tư'),
            Tab(text: 'Dịch vụ'),
          ],
        ),
        Expanded(child: TabBarView(children: [_invCol(i), _svcCol(s)])),
      ],
    ),
  );

  // ─── INV ──────────────────────────────────────
  Widget _invCol(InventoryViewModel vm) {
    return Obx(() {
      final items = _sortInv(vm);
      return Column(
        children: [
          _colHdr(
            'Vật tư',
            Icons.inventory_2_outlined,
            AppColors.info,
            items.length,
            _invSortBy,
            _invAsc,
            () => setState(() {
              _invAsc = !_invAsc;
            }),
            (v) => setState(() => _invSortBy = v),
          ),
          _searchBar(_invSearch, 'Tìm vật tư...', vm.onSearchChanged, () {
            _invSearch.clear();
            vm.clearSearch();
          }),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _invRow(items[i], vm),
            ),
          ),
        ],
      );
    });
  }

  List<InventoryItem> _sortInv(InventoryViewModel vm) {
    final l = List<InventoryItem>.from(vm.filteredItems);
    int c(InventoryItem a, InventoryItem b) {
      switch (_invSortBy) {
        case 'name':
          return a.itemName.compareTo(b.itemName);
        case 'date':
          return (a.createdAt ?? '').compareTo(b.createdAt ?? '');
        case 'cost':
          return a.unitCost.compareTo(b.unitCost);
        default:
          return 0;
      }
    }

    l.sort((a, b) => _invAsc ? c(a, b) : c(b, a));
    return l;
  }

  Widget _invRow(InventoryItem item, InventoryViewModel vm) => _row(
    item.itemName,
    'Nhập: ${_fmt(item.unitCost)}đ',
    item.isPriced,
    item.unitPrice,
    () => _invDlg(item, vm),
  );

  void _invDlg(InventoryItem item, InventoryViewModel vm) => _priceDlg(
    item.itemName,
    Icons.inventory_2,
    'Giá nhập: ${_fmt(item.unitCost)}đ${item.isPriced ? "  |  Hiện tại: ${_fmt(item.unitPrice!)}đ" : ""}',
    item.isPriced ? _fmt(item.unitPrice!) : '',
    (price) => vm.setItemPrice(item.itemId, price),
  );

  // ─── SVC ──────────────────────────────────────
  Widget _svcCol(ServiceViewModel svm) {
    return Obx(() {
      var items = _svcSearch.text.isEmpty
          ? List<ServiceItem>.from(svm.items)
          : svm.items
                .where(
                  (s) => s.serviceName.toLowerCase().contains(
                    _svcSearch.text.toLowerCase(),
                  ),
                )
                .toList();
      int c(ServiceItem a, ServiceItem b) {
        switch (_svcSortBy) {
          case 'name':
            return a.serviceName.compareTo(b.serviceName);
          case 'date':
            return (a.createdAt ?? '').compareTo(b.createdAt ?? '');
          case 'cost':
            return (a.unitPrice ?? 0).compareTo(b.unitPrice ?? 0);
          default:
            return 0;
        }
      }

      items.sort((a, b) => _svcAsc ? c(a, b) : c(b, a));
      return Column(
        children: [
          _colHdr(
            'Dịch vụ',
            Icons.room_service_outlined,
            AppColors.accent,
            items.length,
            _svcSortBy,
            _svcAsc,
            () => setState(() {
              _svcAsc = !_svcAsc;
            }),
            (v) => setState(() => _svcSortBy = v),
          ),
          _searchBar(_svcSearch, 'Tìm dịch vụ...', (_) => setState(() {}), () {
            _svcSearch.clear();
            setState(() {});
          }),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _svcRow(items[i], svm),
            ),
          ),
        ],
      );
    });
  }

  Widget _svcRow(ServiceItem svc, ServiceViewModel svm) => _row(
    svc.serviceName,
    svc.description ?? '',
    svc.isPriced,
    svc.unitPrice,
    () => _svcDlg(svc, svm),
  );

  void _svcDlg(ServiceItem svc, ServiceViewModel svm) => _priceDlg(
    svc.serviceName,
    Icons.room_service,
    svc.isPriced ? 'Giá hiện tại: ${_fmt(svc.unitPrice!)}đ' : 'Chưa có giá bán',
    svc.isPriced ? _fmt(svc.unitPrice!) : '',
    (price) => svm.setPrice(svc.serviceId, price),
  );

  // ─── Shared Widgets ───────────────────────────
  Widget _colHdr(
    String title,
    IconData icon,
    Color color,
    int count,
    String sortBy,
    bool asc,
    VoidCallback toggleAsc,
    ValueChanged<String> onSort,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: color.withOpacity(0.05),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          _sortBtn('Tên', 'name', sortBy, asc, () {
            if (sortBy == 'name') {
              toggleAsc();
            } else {
              onSort('name');
            }
          }),
          const SizedBox(width: 4),
          _sortBtn('Ngày', 'date', sortBy, asc, () {
            if (sortBy == 'date') {
              toggleAsc();
            } else {
              onSort('date');
            }
          }),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortBtn(
    String label,
    String value,
    String current,
    bool asc,
    VoidCallback onTap,
  ) {
    final active = current == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.textHint,
              ),
            ),
            if (active)
              Icon(
                asc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChange,
    VoidCallback onClear,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: ctrl,
        onChanged: onChange,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 18),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
          suffixIcon: ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }

  Widget _row(
    String name,
    String sub,
    bool isPriced,
    double? price,
    VoidCallback onAction,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (sub.isNotEmpty) const SizedBox(height: 2),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isPriced) ...[
                Text(
                  _fmt(price!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                _btn('SỬA', AppColors.info, onAction),
              ] else ...[
                _chip('CHƯA BÁN', AppColors.textHint),
                const SizedBox(width: 8),
                _btn('ĐẶT GIÁ', AppColors.accent, onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
    ),
  );
  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ),
  );

  // ─── Price Dialog ─────────────────────────────
  void _priceDlg(
    String name,
    IconData icon,
    String info,
    String initial,
    Future<String?> Function(double) onSave,
  ) {
    final ctrl = TextEditingController(text: initial);
    final fk = GlobalKey<FormState>();
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: fk,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Giá bán (VNĐ)',
                      hintText: 'Nhập giá bán',
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Nhập giá';
                      final p = double.tryParse(v.replaceAll('.', ''));
                      if (p == null || p <= 0) return 'Giá không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Huỷ'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (fk.currentState!.validate()) {
                              final p = double.parse(
                                ctrl.text.replaceAll('.', '').trim(),
                              );
                              await onSave(p);
                              Get.back();
                              Get.snackbar(
                                'Đã lưu',
                                '${_fmt(p)}đ cho $name',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.success,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'XÁC NHẬN',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
    );
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    if (n.text.isEmpty) return n;
    final d = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return const TextEditingValue(text: '');
    final b = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write('.');
      b.write(d[i]);
    }
    return TextEditingValue(
      text: b.toString(),
      selection: TextSelection.collapsed(offset: b.length),
    );
  }
}
