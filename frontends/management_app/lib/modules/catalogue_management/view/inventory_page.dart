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
  String _selectedFilter = 'ALL';

  final List<Map<String, String>> _filters = const [
    {'value': 'ALL', 'label': 'Tất cả'},
    {'value': 'RESTOCK', 'label': 'Nhập kho'},
    {'value': 'CONSUME', 'label': 'Xuất kho'},
    {'value': 'DAMAGE', 'label': 'Báo hỏng'},
    {'value': 'RECONCILE', 'label': 'Kiểm kê'},
    {'value': 'LOSS', 'label': 'Thất thoát'},
    {'value': 'AUTO_SELL', 'label': 'Bán tự động'},
    {'value': 'UPDATE', 'label': 'Cập nhật'},
    {'value': 'DEACTIVATE', 'label': 'Vô hiệu hóa'},
    {'value': 'REACTIVATE', 'label': 'Khôi phục'},
  ];

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
        title: const Text('Kho & Vật tư'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Làm mới',
            onPressed: () {
              vm.fetchItems();
              vm.fetchAdjustments();
              vm.fetchDeactivatedItems();
            },
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
            _tab(Icons.inventory_2_outlined, 'Tồn kho', 0, vm),
            const SizedBox(width: 6),
            _tab(Icons.history_rounded, 'Lịch sử', 1, vm),
            const SizedBox(width: 6),
            _tab(Icons.restore_rounded, 'Khôi phục', 2, vm),
          ],
        ),
      ),
    );
  }

  Widget _tab(IconData icon, String label, int index, InventoryViewModel vm) {
    final active = vm.selectedTab.value == index;
    return GestureDetector(
      onTap: () {
        vm.selectedTab.value = index;
        if (index == 1) vm.fetchAdjustments();
        if (index == 2) vm.fetchDeactivatedItems();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────────

  Widget _buildSearchBar(InventoryViewModel vm) {
    return Obx(() {
      if (vm.selectedTab.value != 0) return const SizedBox.shrink();
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
    });
  }

  // ─── Tab content ──────────────────────────────────────────────

  Widget _buildTabContent(InventoryViewModel vm) {
    return Obx(() {
      if (vm.isLoading.value &&
          vm.filteredItems.isEmpty &&
          vm.adjustments.isEmpty &&
          vm.deactivatedItems.isEmpty) {
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
          return _buildRestoreTab(vm);
        default:
          return const SizedBox();
      }
    });
  }

  // ─── Tab 0: Stock list ────────────────────────────────────────

  Widget _buildStockTab(InventoryViewModel vm) {
    if (vm.filteredItems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: "Không có vật tư nào",
        subtitle: "Nhấn + để thêm mới",
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (item.description != null && item.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(item.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ),
                    ],
                  ),
                ),
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
                if (item.isPriced) StatusChip(label: "SẴN BÁN", color: AppColors.success) else StatusChip(label: "CHƯA BÁN", color: AppColors.textHint),
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
                    if (item.description != null && item.description!.isNotEmpty)
                      Text(
                        item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
                          if (item.description != null && item.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            "Tồn kho: ${item.stockQuantity}  |  Ngưỡng cảnh báo: ${item.lowStockThreshold}  |  Tổng giá trị: ${_fmt(item.totalValue)}đ",
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
                  "Nhập kho",
                  "Tăng số lượng khi nhập thêm hàng mới vào kho",
                  AppColors.success,
                  () {
                    Get.back();
                    _showAdjustDialog(vm, item, "RESTOCK");
                  },
                ),
                _actionRow(
                  Icons.broken_image_outlined,
                  "Báo hỏng",
                  "Ghi nhận và giảm trừ số lượng vật tư bị hư hỏng",
                  const Color(0xFFF97316),
                  () {
                    Get.back();
                    _showAdjustDialog(vm, item, "DAMAGE");
                  },
                ),
                _actionRow(
                  Icons.balance_outlined,
                  "Kiểm kê kho",
                  "Cập nhật tồn kho theo số lượng thực tế đếm được",
                  AppColors.info,
                  () {
                    Get.back();
                    _showAdjustDialog(vm, item, "RECONCILE");
                  },
                ),
                _actionRow(
                  Icons.report_problem_outlined,
                  "Báo thất thoát",
                  "Ghi nhận hao hụt, mất mát vật tư không rõ nguyên nhân",
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
                  "Thay đổi tên vật tư, giá nhập lẻ hoặc ngưỡng cảnh báo",
                  AppColors.info,
                  () {
                    Get.back();
                    _showItemDialog(vm, existing: item);
                  },
                ),
                _actionRow(
                  Icons.delete_outline,
                  "Vô hiệu hoá",
                  "Tạm ngừng sử dụng vật tư này (có thể khôi phục sau)",
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      ),
    );
  }

  // ─── Tab 1: Adjustment history ────────────────────────────────

  Widget _buildAdjustmentTab(InventoryViewModel vm) {
    final list = _selectedFilter == 'ALL'
        ? vm.adjustments
        : vm.adjustments.where((a) => a.type == _selectedFilter).toList();

    return Column(
      children: [
        // Horizontal scrollable filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              final filter = _filters[i];
              final isSelected = _selectedFilter == filter['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    filter['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: AppColors.surface,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter['value']!;
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? _buildEmptyState(
                  icon: Icons.history_rounded,
                  title: 'Không có dữ liệu',
                  subtitle: 'Không tìm thấy lịch sử phù hợp',
                )
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: vm.fetchAdjustments,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _buildAdjustmentCard(list[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentCard(AdjustmentRecord adj) {
    final typeInfo = _adjustmentTypeInfo(adj.type);
    final isPositive = adj.quantity > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: typeInfo.color.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeInfo.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(typeInfo.icon, size: 20, color: typeInfo.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeInfo.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: typeInfo.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          adj.itemName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (adj.quantity != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (isPositive ? AppColors.success : AppColors.danger)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${isPositive ? "+" : ""}${adj.quantity}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color:
                              isPositive ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    adj.employeeName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(adj.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (adj.description != null &&
                      adj.description!.isNotEmpty) ...[
                    const Spacer(),
                    Flexible(
                      child: Text(
                        adj.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _AdjustmentTypeInfo _adjustmentTypeInfo(String type) {
    switch (type) {
      case 'RESTOCK':
        return _AdjustmentTypeInfo(
            'Nhập kho', Icons.add_circle_outline, AppColors.success);
      case 'CONSUME':
        return _AdjustmentTypeInfo(
            'Xuất kho', Icons.remove_circle_outline, AppColors.warning);
      case 'DAMAGE':
        return _AdjustmentTypeInfo(
            'Báo hỏng', Icons.broken_image_outlined, const Color(0xFFF97316));
      case 'RECONCILE':
        return _AdjustmentTypeInfo(
            'Kiểm kê', Icons.balance_outlined, AppColors.info);
      case 'LOSS':
        return _AdjustmentTypeInfo(
            'Thất thoát', Icons.report_problem_outlined, const Color(0xFFDC2626));
      case 'AUTO_SELL':
        return _AdjustmentTypeInfo(
            'Bán tự động', Icons.point_of_sale, AppColors.accent);
      case 'UPDATE':
        return _AdjustmentTypeInfo(
            'Cập nhật', Icons.edit_note_rounded, AppColors.info);
      case 'DEACTIVATE':
        return _AdjustmentTypeInfo(
            'Vô hiệu hóa', Icons.delete_outline_rounded, const Color(0xFFEF4444));
      case 'REACTIVATE':
        return _AdjustmentTypeInfo(
            'Khôi phục', Icons.settings_backup_restore_rounded, AppColors.success);
      default:
        return _AdjustmentTypeInfo(
            type, Icons.swap_vert, AppColors.textSecondary);
    }
  }

  // ─── Tab 2: Restore deactivated items ─────────────────────────

  Widget _buildRestoreTab(InventoryViewModel vm) {
    if (vm.deactivatedItems.isEmpty && !vm.isLoading.value) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Không có vật tư nào bị vô hiệu',
        subtitle: 'Tất cả vật tư đều đang hoạt động',
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: vm.fetchDeactivatedItems,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: vm.deactivatedItems.length,
        itemBuilder: (_, i) =>
            _buildDeactivatedItemCard(vm.deactivatedItems[i], vm),
      ),
    );
  }

  Widget _buildDeactivatedItemCard(InventoryItem item, InventoryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: AppColors.textHint.withOpacity(0.4),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 22,
                  color: AppColors.textHint,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.textHint,
                      ),
                    ),
                    if (item.description != null && item.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(item.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontStyle: FontStyle.italic)),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Tồn: ${item.stockQuantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Giá nhập: ${_fmt(item.unitCost)}đ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _confirmReactivate(vm, item),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restore, size: 18, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'Khôi phục',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              icon,
              size: 40,
              color: AppColors.textHint.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────

  void _showItemDialog(InventoryViewModel vm, {InventoryItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.itemName ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
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
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả vật tư',
                      hintText: 'VD: Đóng hộp 24 lon, dùng cho minibar...',
                    ),
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
                                            description: descCtrl.text.trim(),
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
                                            description: descCtrl.text.trim(),
                                          );
                                    if (err == null) {
                                      if (isEdit) {
                                        Get.back();
                                        Get.snackbar("Thành công", "Đã cập nhật vật tư", snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success, colorText: Colors.white, duration: const Duration(seconds: 2));
                                      } else {
                                        nameCtrl.clear();
                                        descCtrl.clear();
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

  void _confirmReactivate(InventoryViewModel vm, InventoryItem item) {
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
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.restore,
                    color: AppColors.success,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Khôi phục vật tư',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kích hoạt lại "${item.itemName}"?',
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
                          final err = await vm.reactivateItem(item.itemId);
                          if (err == null) {
                            Get.snackbar(
                              "Thành công",
                              "Đã khôi phục \"${item.itemName}\"",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            Get.snackbar(
                              "Lỗi",
                              err,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.danger,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Khôi phục',
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

  // ─── Helpers ──────────────────────────────────────────────────

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '—';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeStr;
    }
  }

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

class _AdjustmentTypeInfo {
  final String label;
  final IconData icon;
  final Color color;
  _AdjustmentTypeInfo(this.label, this.icon, this.color);
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
