import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:management_app/core/theme/app_theme.dart';
import 'package:management_app/core/widgets/app_widgets.dart';
import 'package:management_app/modules/catalogue_management/viewmodel/inventory_viewmodel.dart';
import 'package:management_app/modules/operation_analysis/viewmodel/service_viewmodel.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'ALL'; // 'ALL', 'SINGLE', 'COMPOSITE'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmt(double value) {
    final s = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final svm = Get.find<ServiceViewModel>();
    final ivm = Get.find<InventoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý dịch vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Làm mới',
            onPressed: () {
              svm.fetchServices();
              ivm.fetchItems();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Thêm dịch vụ',
            onPressed: () => _showServiceDialog(svm, ivm),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          _buildFilterBar(),
          // Search Bar
          _buildSearchBar(),
          // Service List
          Expanded(
            child: Obx(() {
              if (svm.isLoading.value && svm.items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final filtered = svm.items.where((s) {
                // Search query filter
                if (_searchCtrl.text.isNotEmpty) {
                  final q = _searchCtrl.text.toLowerCase();
                  if (!s.serviceName.toLowerCase().contains(q) &&
                      !(s.description ?? '').toLowerCase().contains(q)) {
                    return false;
                  }
                }
                // Type filter
                if (_selectedFilter == 'SINGLE' && s.isComposite) return false;
                if (_selectedFilter == 'COMPOSITE' && !s.isComposite) return false;
                return s.isActive;
              }).toList();

              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.accent,
                onRefresh: () async {
                  await svm.fetchServices();
                  await ivm.fetchItems();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildServiceCard(filtered[i], svm, ivm),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildFilterBar() {
    final filters = [
      {'value': 'ALL', 'label': 'Tất cả'},
      {'value': 'SINGLE', 'label': 'Đơn lẻ'},
      {'value': 'COMPOSITE', 'label': 'Gói phức hợp'},
    ];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final f = filters[i];
          final isSel = _selectedFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSel,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              backgroundColor: AppColors.surface,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f['value']!;
                });
              },
            ),
          );
        },
      ),
    );
  }

=======
  // ─── Summary cards ──────────────────────────────────────────────

  Widget _buildSummary(ServiceViewModel svm, bool isWide) {
    return FadeTransition(
      opacity: _fade,
      child: Obx(() {
        final active = svm.items.where((s) => s.isActive).toList();
        final single = active.where((s) => !s.isComposite).length;
        final composite = active.where((s) => s.isComposite).length;
        final priced = active.where((s) => s.isPriced).length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Tổng dịch vụ',
                  '${active.length}',
                  Icons.room_service_outlined,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Đơn lẻ',
                  '$single',
                  Icons.fiber_manual_record_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  'Phức hợp',
                  '$composite',
                  Icons.widgets_outlined,
                  AppColors.warning,
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Đã đặt giá',
                    '$priced',
                    Icons.monetization_on_outlined,
                    AppColors.success,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
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
            color: Colors.black.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
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

  // ─── Search bar ───────────────────────────────────────────────

>>>>>>> Stashed changes
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 20),
          hintText: 'Tìm kiếm dịch vụ...',
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

<<<<<<< Updated upstream
=======
  // ─── Filter chips ─────────────────────────────────────────────

  Widget _buildFilterBar() {
    final filters = [
      {'value': 'ALL', 'label': 'Tất cả', 'icon': Icons.apps_rounded},
      {
        'value': 'SINGLE',
        'label': 'Đơn lẻ',
        'icon': Icons.fiber_manual_record_outlined,
      },
      {
        'value': 'COMPOSITE',
        'label': 'Gói phức hợp',
        'icon': Icons.widgets_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: filters.map((f) {
          final isSel = _selectedFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = f['value'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
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
                      f['icon'] as IconData,
                      size: 16,
                      color: isSel ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Service list ─────────────────────────────────────────────

  Widget _buildServiceList(ServiceViewModel svm, InventoryViewModel ivm) {
    return Obx(() {
      if (svm.isLoading.value && svm.items.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }

      final filtered = svm.items.where((s) {
        // Search query filter
        if (_searchCtrl.text.isNotEmpty) {
          final q = _searchCtrl.text.toLowerCase();
          if (!s.serviceName.toLowerCase().contains(q) &&
              !(s.description ?? '').toLowerCase().contains(q)) {
            return false;
          }
        }
        // Type filter
        if (_selectedFilter == 'SINGLE' && s.isComposite) return false;
        if (_selectedFilter == 'COMPOSITE' && !s.isComposite) return false;
        return s.isActive;
      }).toList();

      if (filtered.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          await svm.fetchServices();
          await ivm.fetchItems();
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _buildServiceCard(filtered[i], svm, ivm),
        ),
      );
    });
  }

  // ─── Empty state ──────────────────────────────────────────────

>>>>>>> Stashed changes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
<<<<<<< Updated upstream
          Icon(Icons.room_service_outlined, size: 64, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy dịch vụ nào',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
=======
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.room_service_outlined,
              size: 40,
              color: AppColors.textHint.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy dịch vụ nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nhấn + để thêm mới',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
>>>>>>> Stashed changes
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildServiceCard(ServiceItem s, ServiceViewModel svm, InventoryViewModel ivm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
=======
  // ─── Service card (inventory-style) ───────────────────────────

  Color _serviceColor(ServiceItem s) {
    if (!s.isPriced) return AppColors.textHint;
    if (s.isComposite) return AppColors.info;
    return AppColors.primary;
  }

  Widget _buildServiceCard(
    ServiceItem s,
    ServiceViewModel svm,
    InventoryViewModel ivm,
  ) {
    final color = _serviceColor(s);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: () => _showServiceActions(s, svm, ivm),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: icon, name, price
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        s.isComposite
                            ? Icons.widgets_outlined
                            : Icons.room_service,
                        size: 22,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.serviceName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (s.description != null &&
                              s.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                s.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      s.unitPrice != null
                          ? '${_fmt(s.unitPrice!)}đ'
                          : 'Chưa đặt',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: s.isPriced ? color : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.border,
                ),
                const SizedBox(height: 8),
                // Bottom info row
                Row(
                  children: [
                    _infoChip(
                      s.isComposite
                          ? Icons.widgets_outlined
                          : Icons.fiber_manual_record_outlined,
                      'Loại',
                      s.isComposite ? 'Phức hợp' : 'Đơn lẻ',
                      s.isComposite ? AppColors.info : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    if (s.isComposite &&
                        s.recipeItems != null &&
                        s.recipeItems!.isNotEmpty)
                      _infoChip(
                        Icons.inventory_2_outlined,
                        'Vật tư',
                        '${s.recipeItems!.length} mục',
                        AppColors.warning,
                      ),
                    const Spacer(),
                    if (s.isPriced)
                      StatusChip(label: 'ĐÃ ĐẶT GIÁ', color: AppColors.success)
                    else
                      StatusChip(
                        label: 'CHƯA ĐẶT GIÁ',
                        color: AppColors.textHint,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Bottom sheet actions (inventory-style) ───────────────────

  void _showServiceActions(
    ServiceItem s,
    ServiceViewModel svm,
    InventoryViewModel ivm,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
>>>>>>> Stashed changes
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (s.isComposite ? AppColors.info : AppColors.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      s.isComposite ? Icons.widgets_outlined : Icons.room_service,
                      color: s.isComposite ? AppColors.info : AppColors.primary,
                      size: 22,
                    ),
                  ),
<<<<<<< Updated upstream
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
=======
                ),
                const SizedBox(height: 24),
                // Header with service info
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                            (s.isComposite ? AppColors.info : AppColors.primary)
                                .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        s.isComposite
                            ? Icons.widgets_outlined
                            : Icons.room_service,
                        size: 26,
                        color: s.isComposite
                            ? AppColors.info
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.serviceName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (s.description != null &&
                              s.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
>>>>>>> Stashed changes
                            Text(
                              s.serviceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (s.isComposite ? AppColors.info : AppColors.textHint).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.isComposite ? 'Gói phức hợp' : 'Đơn lẻ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: s.isComposite ? AppColors.info : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (s.description != null && s.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            s.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
<<<<<<< Updated upstream
=======
                      ),
                    ),
                  ],
                ),
                // Recipe items preview
                if (s.isComposite &&
                    s.recipeItems != null &&
                    s.recipeItems!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vật tư tiêu hao định mức:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: s.recipeItems!.map((item) {
                            return Chip(
                              label: Text(
                                '${item.itemName} x${item.quantityRequired}',
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: AppColors.border),
                              ),
                            );
                          }).toList(),
                        ),
>>>>>>> Stashed changes
                      ],
                    ),
                  ),
                  Text(
                    s.unitPrice != null ? '${_fmt(s.unitPrice!)}đ' : 'Chưa đặt giá',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
<<<<<<< Updated upstream
            // Recipe items preview (if composite)
            if (s.isComposite && s.recipeItems != null && s.recipeItems!.isNotEmpty) ...[
              const Divider(height: 1, color: AppColors.border),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.background.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vật tư tiêu hao định mức:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: s.recipeItems!.map((item) {
                        return Chip(
                          label: Text('${item.itemName} x${item.quantityRequired}'),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelStyle: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 1, color: AppColors.border),
            // Actions row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showServiceDialog(svm, ivm, existing: s),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Sửa'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDeactivate(s, svm),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Xoá'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
=======
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
              color: color.withValues(alpha: 0.1),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
>>>>>>> Stashed changes
        ),
      ),
    );
  }

  void _confirmDeactivate(ServiceItem s, ServiceViewModel svm) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xoá dịch vụ'),
<<<<<<< Updated upstream
        content: Text('Bạn có chắc muốn vô hiệu hoá dịch vụ "${s.serviceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
=======
        content: Text(
          'Bạn có chắc muốn vô hiệu hoá dịch vụ "${s.serviceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
>>>>>>> Stashed changes
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final err = await svm.deactivateService(s.serviceId);
              if (err == null) {
                Get.snackbar(
                  'Thành công',
                  'Đã xoá dịch vụ',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Lỗi',
                  err,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.danger,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  void _showServiceDialog(ServiceViewModel svm, InventoryViewModel ivm, {ServiceItem? existing}) {
=======
  // ─── Service add/edit dialog ──────────────────────────────────

  void _showServiceDialog(
    ServiceViewModel svm,
    InventoryViewModel ivm, {
    ServiceItem? existing,
  }) {
>>>>>>> Stashed changes
    final nameCtrl = TextEditingController(text: existing?.serviceName ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(
      text: existing?.unitPrice != null ? _fmt(existing!.unitPrice!) : '',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;
    svm.submitError.value = '';

    // Manage recipe items state in dialog
    final isComposite = (existing?.isComposite ?? false).obs;
    final recipeItems = <Map<String, dynamic>>[].obs;

    if (existing?.recipeItems != null) {
      recipeItems.addAll(
        existing!.recipeItems!.map(
          (item) => {
            'itemId': item.itemId,
            'itemName': item.itemName,
            'quantityRequired': item.quantityRequired,
          },
        ),
      );
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
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
                            color: AppColors.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
                            color: AppColors.info,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEdit ? 'Sửa dịch vụ' : 'Thêm dịch vụ mới',
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
                        labelText: 'Tên dịch vụ',
                        hintText: 'VD: Ăn sáng buffet, Giặt ủi...',
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Nhập tên dịch vụ' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả dịch vụ',
                        hintText: 'Mô tả chi tiết nội dung gói...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_ThousandsFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Giá bán (VNĐ)',
                        hintText: 'Giá bán cho khách hàng',
                      ),
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Nhập giá bán';
<<<<<<< Updated upstream
                        if (double.tryParse(v.replaceAll(".", "").trim()) == null) return 'Giá không hợp lệ';
=======
                        if (double.tryParse(v.replaceAll(".", "").trim()) ==
                            null) {
                          return 'Giá không hợp lệ';
                        }
>>>>>>> Stashed changes
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Composite switch
<<<<<<< Updated upstream
                    Obx(() => SwitchListTile(
                          title: const Text(
                            'Là dịch vụ phức hợp',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          subtitle: const Text(
                            'Bao gồm vật tư tiêu hao định mức từ kho',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
=======
                    Obx(
                      () => SwitchListTile(
                        title: const Text(
                          'Là dịch vụ phức hợp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Bao gồm vật tư tiêu hao định mức từ kho',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
>>>>>>> Stashed changes
                          ),
                        ),
                        value: isComposite.value,
                        activeThumbColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          isComposite.value = val;
                        },
                      ),
                    ),
                    // Recipe items configuration
                    Obx(() {
                      if (!isComposite.value) return const SizedBox();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 24, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Định mức Vật tư',
<<<<<<< Updated upstream
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              TextButton.icon(
                                onPressed: () => _addRecipeItemDialog(ivm, recipeItems),
                                icon: const Icon(Icons.add_circle_outline, size: 16),
                                label: const Text('Thêm'),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
=======
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _addRecipeItemDialog(ivm, recipeItems),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                ),
                                label: const Text('Thêm'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
>>>>>>> Stashed changes
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (recipeItems.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'Chưa thêm vật tư nào',
<<<<<<< Updated upstream
                                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
=======
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint,
                                  ),
>>>>>>> Stashed changes
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recipeItems.length,
                              itemBuilder: (context, idx) {
                                final item = recipeItems[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
<<<<<<< Updated upstream
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
=======
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
>>>>>>> Stashed changes
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['itemName'] as String,
                                              style: const TextStyle(
<<<<<<< Updated upstream
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary),
=======
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
>>>>>>> Stashed changes
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Số lượng cần: ${item['quantityRequired']}',
<<<<<<< Updated upstream
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
=======
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
>>>>>>> Stashed changes
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
<<<<<<< Updated upstream
                                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                                        onPressed: () => recipeItems.removeAt(idx),
=======
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.danger,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            recipeItems.removeAt(idx),
>>>>>>> Stashed changes
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    }),
<<<<<<< Updated upstream
                    Obx(() => svm.submitError.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(svm.submitError.value,
                                style: const TextStyle(fontSize: 12, color: AppColors.danger)))
                        : const SizedBox()),
=======
                    Obx(
                      () => svm.submitError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                svm.submitError.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
>>>>>>> Stashed changes
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
<<<<<<< Updated upstream
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
=======
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
>>>>>>> Stashed changes
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
                              isLoading: svm.isSubmitting.value,
                              onPressed: svm.isSubmitting.value
                                  ? null
                                  : () async {
<<<<<<< Updated upstream
                                      if (!formKey.currentState!.validate()) return;
                                      final itemsList = recipeItems
                                          .map((e) => {
                                                'itemId': e['itemId'],
                                                'quantityRequired': e['quantityRequired'],
                                              })
=======
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      final itemsList = recipeItems
                                          .map(
                                            (e) => {
                                              'itemId': e['itemId'],
                                              'quantityRequired':
                                                  e['quantityRequired'],
                                            },
                                          )
>>>>>>> Stashed changes
                                          .toList();

                                      final err = isEdit
                                          ? await svm.updateService(
                                              existing.serviceId,
                                              nameCtrl.text.trim(),
                                              descCtrl.text.trim(),
<<<<<<< Updated upstream
                                              double.parse(priceCtrl.text.replaceAll(".", "").trim()),
=======
                                              double.parse(
                                                priceCtrl.text
                                                    .replaceAll(".", "")
                                                    .trim(),
                                              ),
>>>>>>> Stashed changes
                                              isComposite.value,
                                              itemsList,
                                            )
                                          : await svm.createService(
                                              nameCtrl.text.trim(),
                                              descCtrl.text.trim(),
<<<<<<< Updated upstream
                                              double.parse(priceCtrl.text.replaceAll(".", "").trim()),
=======
                                              double.parse(
                                                priceCtrl.text
                                                    .replaceAll(".", "")
                                                    .trim(),
                                              ),
>>>>>>> Stashed changes
                                              isComposite.value,
                                              itemsList,
                                            );

                                      if (err == null) {
                                        Get.back();
<<<<<<< Updated upstream
                                        Get.snackbar('Thành công',
                                            isEdit ? 'Đã cập nhật dịch vụ' : 'Đã thêm dịch vụ mới',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: AppColors.success,
                                            colorText: Colors.white);
=======
                                        Get.snackbar(
                                          'Thành công',
                                          isEdit
                                              ? 'Đã cập nhật dịch vụ'
                                              : 'Đã thêm dịch vụ mới',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: AppColors.success,
                                          colorText: Colors.white,
                                        );
>>>>>>> Stashed changes
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
    );
  }

<<<<<<< Updated upstream
  void _addRecipeItemDialog(InventoryViewModel ivm, RxList<Map<String, dynamic>> recipeItems) {
=======
  void _addRecipeItemDialog(
    InventoryViewModel ivm,
    RxList<Map<String, dynamic>> recipeItems,
  ) {
>>>>>>> Stashed changes
    InventoryItem? selItem;
    final qtyCtrl = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Chọn vật tư tiêu hao'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<InventoryItem>(
                decoration: const InputDecoration(labelText: 'Vật tư'),
                items: ivm.filteredItems.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item.itemName),
                  );
                }).toList(),
                onChanged: (val) => selItem = val,
                validator: (v) => v == null ? 'Chọn vật tư' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
<<<<<<< Updated upstream
                decoration: const InputDecoration(labelText: 'Số lượng định mức'),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Nhập số lượng';
                  final num = int.tryParse(v.trim());
                  if (num == null || num <= 0) return 'Số lượng phải lớn hơn 0';
=======
                decoration: const InputDecoration(
                  labelText: 'Số lượng định mức',
                ),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Nhập số lượng';
                  final num = int.tryParse(v.trim());
                  if (num == null || num <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }
>>>>>>> Stashed changes
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
<<<<<<< Updated upstream
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate() || selItem == null) return;
              // Check if already added
              final exists = recipeItems.any((e) => e['itemId'] == selItem!.itemId);
              if (exists) {
                Get.back();
                Get.snackbar('Lỗi', 'Vật tư này đã có trong danh mục định mức',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.danger,
                    colorText: Colors.white);
=======
            child: const Text(
              'Huỷ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate() || selItem == null) {
                return;
              }
              // Check if already added
              final exists = recipeItems.any(
                (e) => e['itemId'] == selItem!.itemId,
              );
              if (exists) {
                Get.back();
                Get.snackbar(
                  'Lỗi',
                  'Vật tư này đã có trong danh mục định mức',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.danger,
                  colorText: Colors.white,
                );
>>>>>>> Stashed changes
                return;
              }

              recipeItems.add({
                'itemId': selItem!.itemId,
                'itemName': selItem!.itemName,
                'quantityRequired': int.parse(qtyCtrl.text.trim()),
              });
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
<<<<<<< Updated upstream
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
=======
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
>>>>>>> Stashed changes
          ),
        ],
      ),
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
<<<<<<< Updated upstream
  TextEditingValue formatEditUpdate(TextEditingValue oldVal, TextEditingValue newVal) {
=======
  TextEditingValue formatEditUpdate(
    TextEditingValue oldVal,
    TextEditingValue newVal,
  ) {
>>>>>>> Stashed changes
    if (newVal.text.isEmpty) return newVal;
    final numStr = newVal.text.replaceAll(".", "");
    final number = int.tryParse(numStr);
    if (number == null) return oldVal;

    final s = number.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(reg, (m) => '${m[1]}.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
