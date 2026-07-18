import 'package:get/get.dart';
import 'package:hms_shared/constants/api_constants.dart';
import 'package:hms_shared/network/dio_client.dart';

class InventoryItem {
  final String itemId;
  final String itemName;
  final int stockQuantity;
  final double unitCost;
  final double? unitPrice;
  bool get isPriced => unitPrice != null;
  final int lowStockThreshold;
  final bool isActive;
  final String? createdAt;

  InventoryItem({
    required this.itemId,
    required this.itemName,
    required this.stockQuantity,
    required this.unitCost,
    required this.lowStockThreshold,
    required this.isActive,
    this.createdAt,
    this.unitPrice,
  });

  double get totalValue => stockQuantity * unitCost;
  bool get isLow => stockQuantity <= lowStockThreshold;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    itemId: json['itemId'] as String? ?? '',
    itemName: json['itemName'] as String? ?? '',
    stockQuantity: json['stockQuantity'] as int? ?? 0,
    unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0,
    unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] as String?,
  );
}

class InventoryViewModel extends GetxController {
  final DioClient _dioClient;

  final RxList<InventoryItem> _items = <InventoryItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTab = 0.obs;
  final RxBool isGridView = false.obs;

  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;

  InventoryViewModel(this._dioClient);

  List<InventoryItem> get filteredItems {
    if (searchQuery.value.isEmpty) return _items;
    final q = searchQuery.value.toLowerCase();
    return _items.where((i) => i.itemName.toLowerCase().contains(q)).toList();
  }

  int get totalItems => _items.length;
  int get lowStockCount => _items.where((i) => i.isLow).length;
  int get outOfStockCount => _items.where((i) => i.stockQuantity == 0).length;
  double get totalValue => _items.fold(0, (sum, i) => sum + i.totalValue);

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      final response = await _dioClient.dio.get(ApiConstants.inventoryItems);
      _items.value = (response.data as List)
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createItem(String name, double cost, int threshold) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dioClient.dio.post(
        ApiConstants.inventoryItems,
        data: {'itemName': name, 'unitCost': cost, 'threshold': threshold},
      );
      await fetchItems();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> updateItem(
    String id,
    String name,
    double cost,
    int threshold,
  ) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dioClient.dio.put(
        ApiConstants.inventoryItemById(id),
        data: {'itemName': name, 'unitCost': cost, 'threshold': threshold},
      );
      await fetchItems();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> adjustStock(
    String itemId,
    int qty,
    String type,
    String reason,
  ) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dioClient.dio.post(
        ApiConstants.inventoryAdjustments,
        data: {
          'itemId': itemId,
          'quantity': qty,
          'type': type,
          'reason': reason,
        },
      );
      await fetchItems();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }


  Future<String?> setItemPrice(String itemId, double unitPrice) async {
    try {
      await _dioClient.dio.patch(ApiConstants.inventoryItemPrice(itemId), data: {"unitPrice": unitPrice});
      await fetchItems();
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }
  Future<String?> deactivateItem(String id) async {
    try {
      await _dioClient.dio.patch(ApiConstants.inventoryItemDeactivate(id));
      await fetchItems();
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  void onSearchChanged(String value) => searchQuery.value = value;
  void clearSearch() => searchQuery.value = '';
  void toggleView() => isGridView.value = !isGridView.value;

  String _extractError(dynamic e) {
    try {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message'))
        return data['message'] as String;
    } catch (_) {}
    final s = e.toString();
    if (s.contains('RuntimeException:'))
      return s.split('RuntimeException:').last.trim();
    return 'Có lỗi xảy ra, vui lòng thử lại';
  }
}
