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

  ServiceItem({
    required this.serviceId,
    required this.serviceName,
    this.description,
    this.unitPrice,
    required this.isActive,
    this.createdAt,
  });

  bool get isPriced => unitPrice != null;

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    serviceId: json['serviceId'] as String? ?? '',
    serviceName: json['serviceName'] as String? ?? '',
    description: json['description'] as String?,
    unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] as String?,
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
      if (data is Map && data.containsKey('message'))
        return data['message'] as String;
    } catch (_) {}
    return 'Có lỗi xảy ra';
  }
}
