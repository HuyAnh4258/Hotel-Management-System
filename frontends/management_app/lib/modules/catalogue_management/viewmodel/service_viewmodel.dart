import 'package:get/get.dart';
import 'package:hms_shared/constants/api_constants.dart';
import 'package:hms_shared/network/dio_client.dart';

class ServiceItem {
  final String serviceId;
  final String serviceName;
  final String? description;
  final double? unitPrice;
  final bool isActive;
  final String? createdAt;
  final bool isComposite;
  final List<RecipeItem>? recipeItems;

  ServiceItem({
    required this.serviceId,
    required this.serviceName,
    this.description,
    this.unitPrice,
    required this.isActive,
    this.createdAt,
    this.isComposite = false,
    this.recipeItems,
  });

  bool get isPriced => unitPrice != null;

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        serviceId: json['serviceId'] as String? ?? '',
        serviceName: json['serviceName'] as String? ?? '',
        description: json['description'] as String?,
        unitPrice: (json['unitPrice'] as num?)?.toDouble(),
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] as String?,
        isComposite: json['isComposite'] as bool? ?? false,
        recipeItems: (json['recipeItems'] as List?)
            ?.map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RecipeItem {
  final String itemId;
  final String itemName;
  final int quantityRequired;
  final double? unitPrice;

  RecipeItem({
    required this.itemId,
    required this.itemName,
    required this.quantityRequired,
    this.unitPrice,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) => RecipeItem(
        itemId: json['itemId'] as String? ?? '',
        itemName: json['itemName'] as String? ?? '',
        quantityRequired: json['quantityRequired'] as int? ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      );
}

class ServiceViewModel extends GetxController {
  final DioClient _dio;

  final RxList<ServiceItem> items = <ServiceItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;

  ServiceViewModel(this._dio);

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      final resp = await _dio.dio.get(ApiConstants.services);
      items.value = (resp.data as List)
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createService(
    String name,
    String description,
    double price,
    bool isComposite,
    List<Map<String, dynamic>> recipeItems,
  ) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dio.dio.post(
        ApiConstants.services,
        data: {
          'serviceName': name,
          'description': description,
          'unitPrice': price,
          'isComposite': isComposite,
          'recipeItems': recipeItems,
        },
      );
      await fetchServices();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> updateService(
    String id,
    String name,
    String description,
    double price,
    bool isComposite,
    List<Map<String, dynamic>> recipeItems,
  ) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dio.dio.put(
        '${ApiConstants.services}/$id',
        data: {
          'serviceName': name,
          'description': description,
          'unitPrice': price,
          'isComposite': isComposite,
          'recipeItems': recipeItems,
        },
      );
      await fetchServices();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> deactivateService(String id) async {
    try {
      await _dio.dio.patch('${ApiConstants.services}/$id/deactivate');
      await fetchServices();
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> setPrice(String serviceId, double unitPrice) async {
    isSubmitting.value = true;
    submitError.value = '';
    try {
      await _dio.dio.patch(
        ApiConstants.servicePrice(serviceId),
        data: {'unitPrice': unitPrice},
      );
      await fetchServices();
      return null;
    } catch (e) {
      submitError.value = _extractError(e);
      return submitError.value;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _extractError(dynamic e) {
    try {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
    } catch (_) {}
    return 'Có lỗi xảy ra';
  }
}
