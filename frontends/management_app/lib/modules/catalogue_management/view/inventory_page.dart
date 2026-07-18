import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/core/widgets/app_widgets.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
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
    final vm = Get.find<InventoryViewModel>();
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kho & Chi phí'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Làm mới',
            onPressed: () => vm.fetchItems(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Thêm vật tư',
            onPressed: () => _showItemDialog(vm),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(vm, isWide),
          _buildTabBar(vm),
          _buildSearchBar(vm),
          Expanded(child: _buildTabContent(vm)),
        ],
      ),
    );
  }

  // ─── Summary ──────────────────────────────────────────────────

  Widget _buildSummary(InventoryViewModel vm, bool isWide) {
    return FadeTransition(
      opacity: _fade,
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Tổng vật tư',
                  '${vm.totalItems}',
                  Icons.inventory_2_outlined,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Sắp hết',
                  '${vm.lowStockCount}',
                  Icons.warning_amber_rounded,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Đã hết',
                  '${vm.outOfStockCount}',
                  Icons.inventory_2,
                  AppColors.danger,
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Tổng giá trị',
                    _fmt(vm.totalValue),
                    Icons.monetization_on_outlined,
                    AppColors.success,
                  ),
                ),
              ],
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

  // ─── Tab bar ──────────────────────────────────────────────────

  Widget _buildTabBar(InventoryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Obx(
        () => Row(
          children: [
            _tab('Tồn kho', 0, vm),
            const SizedBox(width: 4),
            _tab('Điều chỉnh', 1, vm),
            const SizedBox(width: 4),
            _tab('Báo cáo', 2, vm),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index, InventoryViewModel vm) {
    final active = vm.selectedTab.value == index;
    return GestureDetector(
      onTap: () => vm.selectedTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────────

  Widget _buildSearchBar(InventoryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: vm.onSearchChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Tìm vật tư...",
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
          const SizedBox(width: 8),
          Obx(
            () => IconButton(
              icon: Icon(
                vm.isGridView.value ? Icons.list : Icons.grid_view_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
              tooltip: vm.isGridView.value
                  ? "Xem dạng danh sách"
                  : "Xem dạng lưới",
              onPressed: vm.toggleView,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab content ──────────────────────────────────────────────

  Widget _buildTabContent(InventoryViewModel vm) {
    return Obx(() {
      if (vm.isLoading.value && vm.filteredItems.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }

      switch (vm.selectedTab.value) {
        case 0:
          return _buildStockTab(vm);
        case 1:
          return _buildAdjustmentTab(vm);
        case 2:
          return _buildReportTab(vm);
        default:
          return const SizedBox();
      }
    });
  }

  // ─── Tab 0: Stock list ────────────────────────────────────────

  Widget _buildStockTab(InventoryViewModel vm) {
    if (vm.filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              "Không có vật tư nào",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              "Nhấn + để thêm mới",
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: vm.fetchItems,
      child: Obx(() {
        if (vm.isGridView.value) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 600 ? 4 : 3;
              final gap = 10.0;
              final cardW =
                  (constraints.maxWidth - 32 - (cols - 1) * gap) / cols;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: vm.filteredItems
                      .map(
                        (item) => SizedBox(
                          width: cardW,
                          child: _buildGridItemCard(item, vm),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: vm.filteredItems.length,
          itemBuilder: (_, i) => _buildListItemCard(vm.filteredItems[i], vm),
        );
      }),
    );
  }

  Color _stockColor(InventoryItem item) {
    if (item.stockQuantity == 0) return AppColors.danger;
    if (item.isLow) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildListItemCard(InventoryItem item, InventoryViewModel vm) {
    final color = _stockColor(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16), elevation: 2, shadowColor: Colors.black.withOpacity(0.06),
        child: InkWell(
          onTap: () => _showItemActions(item, vm), borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: color, width: 4))),
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)), child: Icon(Icons.inventory_2, size: 22, color: color)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                const SizedBox(width: 12),
                Text("${item.stockQuantity}/${item.lowStockThreshold}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
              ]),
              const SizedBox(height: 10),
              Divider(height: 1, thickness: 0.5, color: AppColors.border),
              const SizedBox(height: 8),
              Row(children: [
                _infoChip(Icons.shopping_cart_outlined, "Giá nhập", "${_fmt(item.unitCost)}đ"),
                const SizedBox(width: 16),
                _infoChip(Icons.sell_outlined, "Giá bán", item.isPriced ? "${_fmt(item.unitPrice!)}đ" : "Chưa đặt", item.isPriced ? AppColors.accent : AppColors.textHint),
                const Spacer(),
                if (item.isPriced) StatusChip(label: "ĐÃ BÁN", color: AppColors.accent) else StatusChip(label: "CHƯA BÁN", color: AppColors.textHint),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, [Color? valueColor]) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text("$label: ", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
    ]);
  }
  Widget _buildGridItemCard(InventoryItem item, InventoryViewModel vm) {
    final color = _stockColor(item);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showItemActions(item, vm),
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.inventory_2, size: 18, color: color),
                    Text(
                      "${item.stockQuantity}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 2, color: color),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: item.isLow
                            ? AppColors.danger
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _fmt(item.unitCost),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemActions(InventoryItem item, InventoryViewModel vm) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.52,
        minChildSize: 0.35,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      size: 26,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tồn: ${item.stockQuantity}  |  Ngưỡng: ${item.lowStockThreshold}  |  ${_fmt(item.totalValue)}đ",
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
              const SizedBox(height: 8),
              if (item.isLow)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: StatusChip(
                    label: "Dưới ngưỡng tồn kho — cần nhập thêm",
                    color: AppColors.danger,
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                "Điều chỉnh kho",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _actionRow(
                Icons.add_circle_outline,
                "Nhập kho (RESTOCK)",
                AppColors.success,
                () {
                  Get.back();
                  _showAdjustDialog(vm, item, "RESTOCK");
                },
              ),
              _actionRow(
                Icons.remove_circle_outline,
                "Xuất kho (CONSUME)",
                AppColors.warning,
                () {
                  Get.back();
                  _showAdjustDialog(vm, item, "CONSUME");
                },
              ),
              _actionRow(
                Icons.broken_image_outlined,
                "Báo hỏng (DAMAGE)",
                const Color(0xFFF97316),
                () {
                  Get.back();
                  _showAdjustDialog(vm, item, "DAMAGE");
                },
              ),
              _actionRow(
                Icons.balance_outlined,
                "Kiểm kê (RECONCILE)",
                AppColors.info,
                () {
                  Get.back();
                  _showAdjustDialog(vm, item, "RECONCILE");
                },
              ),
              _actionRow(
                Icons.report_problem_outlined,
                "Thất thoát (LOSS)",
                const Color(0xFFDC2626),
                () {
                  Get.back();
                  _showAdjustDialog(vm, item, "LOSS");
                },
              ),
              const SizedBox(height: 12),
              const Text(
                "Quản lý",
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
                "Sửa thông tin",
                AppColors.info,
                () {
                  Get.back();
                  _showItemDialog(vm, existing: item);
                },
              ),
              _actionRow(
                Icons.delete_outline,
                "Vô hiệu hoá",
                AppColors.danger,
                () {
                  Get.back();
                  _confirmDeactivate(vm, item);
                },
              ),
            ],
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }

  // ─── Tab 1: Adjustment history (placeholder) ──────────────────

  Widget _buildAdjustmentTab(InventoryViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textHint.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lịch sử điều chỉnh',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tính năng đang phát triển',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Report (placeholder) ──────────────────────────────

  Widget _buildReportTab(InventoryViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: AppColors.textHint.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Báo cáo chi phí',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tính năng đang phát triển',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────

  void _showItemDialog(InventoryViewModel vm, {InventoryItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.itemName ?? '');
    final costCtrl = TextEditingController(
      text: existing != null ? _fmt(existing.unitCost) : '',
    );
    final thresholdCtrl = TextEditingController(
      text: existing != null ? '${existing.lowStockThreshold}' : '',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;
    vm.submitError.value = '';

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
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
                        isEdit ? 'Sửa vật tư' : 'Thêm vật tư mới',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên vật tư',
                      hintText: 'VD: Xà phòng, Nước suối...',
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Nhập tên' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Giá nhập lẻ (VNĐ)',
                      hintText: 'Giá vốn nhập kho mỗi đơn vị',
                    ),
                    validator: (v) { if (v!.trim().isEmpty) return 'Nhập giá'; if (double.tryParse(v.replaceAll(".", "").trim()) == null) return 'Giá không hợp lệ'; return null; },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: thresholdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ngưỡng tồn kho',
                      hintText: 'Số lượng tối thiểu cần có',
                    ),
                    validator: (v) { if (v!.trim().isNotEmpty && int.tryParse(v.trim()) == null) return 'Số không hợp lệ'; return null; },
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      "CHÚ Ý: Hệ thống sẽ cảnh báo khi số lượng tồn kho ≤ ngưỡng tồn kho. Hãy điểu chình ngưỡng tồn kho theo nhu cầu sử dụng của khách",
                      style: TextStyle(fontSize: 11, color: AppColors.textHint),
                    ),
                  ),
                  Obx(() => vm.submitError.isNotEmpty ? Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.submitError.value, style: const TextStyle(fontSize: 12, color: AppColors.danger))) : const SizedBox()),
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
                        child: Obx(
                          () => PrimaryButton(
                            label: isEdit ? 'CẬP NHẬT' : 'THÊM MỚI',
                            isLoading: vm.isSubmitting.value,
                            onPressed: vm.isSubmitting.value
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;
                                    final err = isEdit
                                        ? await vm.updateItem(
                                            existing.itemId,
                                            nameCtrl.text.trim(),
                                            double.parse(
                                              costCtrl.text
                                                  .replaceAll(".", "")
                                                  .trim(),
                                            ),
                                            int.tryParse(
                                                  thresholdCtrl.text.trim(),
                                                ) ??
                                                5,
                                          )
                                        : await vm.createItem(
                                            nameCtrl.text.trim(),
                                            double.parse(
                                              costCtrl.text
                                                  .replaceAll(".", "")
                                                  .trim(),
                                            ),
                                            int.tryParse(
                                                  thresholdCtrl.text.trim(),
                                                ) ??
                                                5,
                                          );
                                    if (err == null) {
                                      if (isEdit) {
                                        Get.back();
                                        Get.snackbar("Thành công", "Đã cập nhật vật tư", snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success, colorText: Colors.white, duration: const Duration(seconds: 2));
                                      } else {
                                        nameCtrl.clear();
                                        costCtrl.clear();
                                        thresholdCtrl.clear();
                                        formKey.currentState?.reset();
                                        Get.snackbar("Thành công", "Đã tạo vật tư mới", snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success, colorText: Colors.white, duration: const Duration(seconds: 2));
                                      }
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
      barrierDismissible: false,
    );
  }

  void _showAdjustDialog(
    InventoryViewModel vm,
    InventoryItem item,
    String type,
  ) {
    vm.submitError.value = '';
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final isOut = type == "CONSUME" || type == "DAMAGE";
    final title = type == 'CONSUME'
        ? 'Xuất kho'
        : type == 'DAMAGE'
        ? 'Báo hỏng'
        : type == 'RESTOCK'
        ? 'Nhập kho'
        : 'Kiểm kê';
    final color = type == "RECONCILE"
        ? AppColors.info
        : isOut
        ? AppColors.warning
        : AppColors.success;
    final icon = type == "RECONCILE"
        ? Icons.balance
        : isOut
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
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
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$title — ${item.itemName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tồn hiện tại: ${item.stockQuantity}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số lượng',
                      hintText: type == "RESTOCK"
                          ? "Số lượng nhập kho"
                          : type == "RECONCILE"
                          ? "Số lượng thực tế sau kiểm kê"
                          : "Số lượng xuất",
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Nhập số lượng';
                      final qty = int.tryParse(v.trim());
                      if (qty == null || qty <= 0)
                        return 'Số lượng không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lý do',
                      hintText: 'Nhập lý do điều chỉnh...',
                    ),
                  ),
                  Obx(() => vm.submitError.isNotEmpty ? Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.submitError.value, style: const TextStyle(fontSize: 12, color: AppColors.danger))) : const SizedBox()),
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
                        child: Obx(
                          () => PrimaryButton(
                            label: title.toUpperCase(),
                            icon: icon,
                            isLoading: vm.isSubmitting.value,
                            onPressed: vm.isSubmitting.value
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;
                                    final err = await vm.adjustStock(
                                      item.itemId,
                                      int.parse(qtyCtrl.text.trim()),
                                      type,
                                      reasonCtrl.text.trim(),
                                    );
                                    if (err == null) {
                                      Get.back();
                                      Get.snackbar("Thành công", "Đã điều chỉnh tồn kho", snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success, colorText: Colors.white, duration: const Duration(seconds: 2));
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
      barrierDismissible: false,
    );
  }

  void _confirmDeactivate(InventoryViewModel vm, InventoryItem item) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Vô hiệu hoá vật tư',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn có chắc muốn vô hiệu hoá "${item.itemName}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Huỷ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await vm.deactivateItem(item.itemId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
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
      barrierDismissible: true,
    );
  }

  // ─── Format ───────────────────────────────────────────────────

  String _fmt(double value) {
    final parts = value.toStringAsFixed(0).split(".");
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(".");
      buf.write(intPart[i]);
    }
    return buf.toString();
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.isEmpty) return const TextEditingValue(text: "");
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(".");
      buf.write(digits[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}
