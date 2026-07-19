import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hms_shared/auth/token_storage.dart';

// ============================================================
// MODELS
// ============================================================

class RoomModel {
  final String roomId;
  final String roomName;
  final int floorNumber;
  final String status;
  final String description;
  final bool isActive;
  final RoomTypeModel? roomType;

  RoomModel({
    required this.roomId,
    required this.roomName,
    required this.floorNumber,
    required this.status,
    required this.description,
    required this.isActive,
    this.roomType,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
      floorNumber: int.tryParse(json['floorNumber']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'AVAILABLE',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == true,
      roomType: json['roomType'] != null
          ? RoomTypeModel.fromJson(Map<String, dynamic>.from(json['roomType'] as Map))
          : null,
    );
  }

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Sẵn sàng';
      case 'OCCUPIED':
        return 'Đang có khách';
      case 'DIRTY':
        return 'Chưa dọn';
      case 'CLEANING':
        return 'Đang dọn';
      case 'MAINTENANCE':
        return 'Bảo trì';
      default:
        return status;
    }
  }
}

class RoomTypeModel {
  final String roomTypeId;
  final String typeName;
  final String description;
  final double basePrice;
  final int maxOccupancy;
  final bool isActive;
  final String imageUrl;

  RoomTypeModel({
    required this.roomTypeId,
    required this.typeName,
    required this.description,
    required this.basePrice,
    required this.maxOccupancy,
    required this.isActive,
    required this.imageUrl,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      roomTypeId: json['roomTypeId']?.toString() ?? '',
      typeName: json['typeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
      maxOccupancy: int.tryParse(json['maxOccupancy']?.toString() ?? '2') ?? 2,
      isActive: json['isActive'] == true,
      imageUrl: json['imageURL']?.toString() ?? '',
    );
  }
}

// ============================================================
// API CLIENT
// ============================================================

class PropertyApi {
  PropertyApi._();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    } catch (_) {}
    return 'http://localhost:8080/api';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage().getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

  // --- Rooms ---
  static Future<List<RoomModel>> getRooms() async {
    final response = await _dio.get('$_baseUrl/rooms/all');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<RoomModel> createRoom(Map<String, dynamic> payload) async {
    final response = await _dio.post('$_baseUrl/rooms', data: payload);
    return RoomModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  static Future<RoomModel> updateRoom(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('$_baseUrl/rooms/$id', data: payload);
    return RoomModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  static Future<void> deactivateRoom(String id) async {
    await _dio.put('$_baseUrl/rooms/$id/deactivate');
  }

  static Future<void> activateRoom(String id) async {
    await _dio.put('$_baseUrl/rooms/$id/activate');
  }

  // --- Room Types ---
  static Future<List<RoomTypeModel>> getRoomTypes() async {
    final response = await _dio.get('$_baseUrl/room-types');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomTypeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<RoomTypeModel> createRoomType(Map<String, dynamic> payload) async {
    final response = await _dio.post('$_baseUrl/room-types', data: payload);
    return RoomTypeModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  static Future<RoomTypeModel> updateRoomType(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('$_baseUrl/room-types/$id', data: payload);
    return RoomTypeModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  static Future<void> deactivateRoomType(String id) async {
    await _dio.put('$_baseUrl/room-types/$id/deactivate');
  }

  static Future<void> activateRoomType(String id) async {
    await _dio.put('$_baseUrl/room-types/$id/activate');
  }
}

// ============================================================
// VIEW MODEL
// ============================================================

class PropertyViewModel extends GetxController {
  final RxInt selectedTab = 0.obs; // 0: Rooms, 1: RoomTypes
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Raw lists
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxList<RoomTypeModel> roomTypes = <RoomTypeModel>[].obs;

  // Filtered lists
  final RxList<RoomModel> filteredRooms = <RoomModel>[].obs;
  final RxList<RoomTypeModel> filteredRoomTypes = <RoomTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  Future<void> refreshAllData() async {
    isLoading.value = true;
    try {
      final rList = await PropertyApi.getRooms();
      final rtList = await PropertyApi.getRoomTypes();
      rooms.value = rList;
      roomTypes.value = rtList;
      applySearch();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu phòng & hạng phòng: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
    searchQuery.value = '';
    applySearch();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applySearch();
  }

  void applySearch() {
    final q = searchQuery.value.toLowerCase().trim();
    if (selectedTab.value == 0) {
      if (q.isEmpty) {
        filteredRooms.value = rooms;
      } else {
        filteredRooms.value = rooms.where((r) {
          return r.roomId.toLowerCase().contains(q) ||
              r.roomName.toLowerCase().contains(q) ||
              r.statusDisplay.toLowerCase().contains(q) ||
              (r.roomType?.typeName.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    } else {
      if (q.isEmpty) {
        filteredRoomTypes.value = roomTypes;
      } else {
        filteredRoomTypes.value = roomTypes.where((rt) {
          return rt.typeName.toLowerCase().contains(q) ||
              rt.description.toLowerCase().contains(q);
        }).toList();
      }
    }
  }

  // --- KPI Metrics ---
  int get totalRooms => rooms.length;
  int get availableRooms => rooms.where((r) => r.status == 'AVAILABLE' && r.isActive).length;
  int get dirtyRooms => rooms.where((r) => r.status == 'DIRTY' && r.isActive).length;
  int get maintenanceRooms => rooms.where((r) => r.status == 'MAINTENANCE' && r.isActive).length;
  int get totalRoomTypes => roomTypes.length;

  // --- CRUD Action Helpers ---
  Future<void> saveRoom({
    required String roomId,
    required String roomName,
    required int floorNumber,
    required String roomTypeId,
    required String description,
    required bool isEdit,
  }) async {
    isLoading.value = true;
    try {
      final payload = {
        'roomId': roomId,
        'roomName': roomName,
        'floorNumber': floorNumber,
        'roomTypeId': roomTypeId,
        'description': description,
      };

      if (isEdit) {
        await PropertyApi.updateRoom(roomId, payload);
      } else {
        await PropertyApi.createRoom(payload);
      }
      await refreshAllData();
      Get.snackbar('Thành công', isEdit ? 'Đã cập nhật phòng' : 'Đã tạo phòng mới',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Thất bại', 'Lỗi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleRoomActive(String id, bool active) async {
    isLoading.value = true;
    try {
      if (active) {
        await PropertyApi.activateRoom(id);
      } else {
        await PropertyApi.deactivateRoom(id);
      }
      await refreshAllData();
      Get.snackbar('Thành công', active ? 'Đã kích hoạt lại phòng' : 'Đã vô hiệu hóa phòng',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đổi trạng thái: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveRoomType({
    required String id,
    required String typeName,
    required double basePrice,
    required int maxOccupancy,
    required String description,
    required bool isEdit,
  }) async {
    isLoading.value = true;
    try {
      final payload = {
        'typeName': typeName,
        'basePrice': basePrice,
        'maxOccupancy': maxOccupancy,
        'description': description,
      };

      if (isEdit) {
        await PropertyApi.updateRoomType(id, payload);
      } else {
        await PropertyApi.createRoomType(payload);
      }
      await refreshAllData();
      Get.snackbar('Thành công', isEdit ? 'Đã cập nhật hạng phòng' : 'Đã tạo hạng phòng mới',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Thất bại', 'Lỗi: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleRoomTypeActive(String id, bool active) async {
    isLoading.value = true;
    try {
      if (active) {
        await PropertyApi.activateRoomType(id);
      } else {
        await PropertyApi.deactivateRoomType(id);
      }
      await refreshAllData();
      Get.snackbar('Thành công', active ? 'Đã kích hoạt hạng phòng' : 'Đã vô hiệu hóa hạng phòng',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đổi trạng thái: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}