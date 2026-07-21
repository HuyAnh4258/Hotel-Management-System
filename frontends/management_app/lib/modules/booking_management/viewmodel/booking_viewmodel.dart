import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BookingApi {
  BookingApi._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/booking';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/booking';
    } catch (_) {}
    return 'http://localhost:8080/api/booking';
  }

  static String get serviceOrderBaseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/orders';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/orders';
    } catch (_) {}
    return 'http://localhost:8080/api/orders';
  }

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static final Dio _serviceOrderDio = Dio(
    BaseOptions(
      baseUrl: serviceOrderBaseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<HomepageData> getHomepage() async {
    final response = await _dio.get('/homepage');
    return HomepageData.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<List<BookingSummary>> getBookings({
    String? date,
    String? userId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (date != null && date.isNotEmpty) {
      queryParameters['date'] = date;
    }
    if (userId != null && userId.isNotEmpty) {
      queryParameters['userId'] = userId;
    }

    final response = await _dio.get(
      '',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (e) => BookingSummary.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static Future<List<RoomModel>> getAvailableRooms({
    required String checkin,
    required String checkout,
  }) async {
    final response = await _dio.get(
      '/available-rooms',
      queryParameters: {'checkin': checkin, 'checkout': checkout},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<List<RoomModel>> getRoomsByStatus({String? status}) async {
    final response = await _dio.get(
      '/rooms',
      queryParameters: status == null || status.isEmpty
          ? null
          : {'status': status},
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<BookingSummary> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final response = await _dio.patch(
      '/$bookingId/status',
      queryParameters: {'status': status},
    );
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<List<RoomModel>> getChangeableRooms(String bookingId) async {
    final response = await _dio.get('/$bookingId/changeable-rooms');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<BookingSummary> updateBookingDetails(
    String bookingId,
    CreateBookingPayload payload,
  ) async {
    final response = await _dio.patch('/$bookingId', data: payload.toJson());
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<BookingSummary> changeBookingRoom(
    String bookingId,
    String roomId,
  ) async {
    final response = await _dio.patch(
      '/$bookingId/change-room',
      queryParameters: {'roomId': roomId},
    );
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<BookingSummary> requestCancelBooking(String bookingId) async {
    final response = await _dio.patch(
      '/$bookingId/status',
      queryParameters: {'status': 'WAITING_APPROVAL'},
    );
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<BookingSummary> approveCancelBooking(String bookingId) async {
    final response = await _dio.patch('/$bookingId/approve-cancel');
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<BookingSummary> rejectCancelBooking(String bookingId) async {
    final response = await _dio.patch('/$bookingId/reject-cancel');
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<BookingSummary> cancelCancelRequest(String bookingId) async {
    final response = await _dio.patch(
      '/$bookingId/status',
      queryParameters: {'status': 'PENDING'},
    );
    return BookingSummary.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<void> createBooking(CreateBookingPayload payload) async {
    await _dio.post('', data: payload.toJson());
  }

  static Future<List<FeedbackModel>> getFeedbacks() async {
    final response = await _dio.get('/feedbacks');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => FeedbackModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<FeedbackModel> submitFeedback(
    SubmitFeedbackPayload payload,
  ) async {
    final response = await _dio.post('/feedbacks', data: payload.toJson());
    return FeedbackModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<List<HotelServiceModel>> getServices() async {
    final response = await _serviceOrderDio.get('/services');
    final data = response.data as List<dynamic>;
    return data
        .map(
          (e) =>
              HotelServiceModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static Future<List<ServiceOrderModel>> getServiceOrders() async {
    final response = await _serviceOrderDio.get('');
    final data = response.data as List<dynamic>;
    return data
        .map(
          (e) =>
              ServiceOrderModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  static Future<ServiceOrderModel> createServiceOrder(
    CreateServiceOrderPayload payload,
  ) async {
    final response = await _serviceOrderDio.post('', data: payload.toJson());
    return ServiceOrderModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<ServiceOrderModel> cancelServiceOrder(String orderId) async {
    final response = await _serviceOrderDio.patch('/$orderId/cancel');
    return ServiceOrderModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<ServiceOrderModel> updateServiceOrderStatus(
    String orderId,
    String status,
  ) async {
    final response = await _serviceOrderDio.patch(
      '/$orderId/status',
      queryParameters: {'status': status},
    );
    return ServiceOrderModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

class CreateBookingPayload {
  CreateBookingPayload({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.userId,
    required this.roomTypeId,
    required this.roomId,
    required this.expectedCheckin,
    required this.expectedCheckout,
  });

  final String fullName;
  final String phone;
  final String email;
  final String userId;
  final String roomTypeId;
  final String roomId;
  final String expectedCheckin;
  final String expectedCheckout;

  Map<String, dynamic> toJson() => {
    'guestName': fullName,
    'phone': phone,
    'email': email,
    'userId': userId,
    'roomIds': [roomId],
    'expectedCheckin': expectedCheckin,
    'expectedCheckout': expectedCheckout,
  };
}

class HomepageData {
  HomepageData({required this.roomTypes, required this.rooms});

  final List<RoomTypeModel> roomTypes;
  final List<RoomModel> rooms;

  factory HomepageData.empty() => HomepageData(roomTypes: [], rooms: []);

  factory HomepageData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> typeJson = (json['roomTypes'] as List<dynamic>? ?? []);
    final List<dynamic> roomJson =
        (json['availableRooms'] as List<dynamic>? ??
        json['rooms'] as List<dynamic>? ??
        []);

    return HomepageData(
      roomTypes: typeJson
          .map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rooms: roomJson
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BookingSummary {
  BookingSummary({
    required this.bookingId,
    required this.guestName,
    required this.phone,
    required this.email,
    required this.expectedCheckin,
    required this.expectedCheckout,
    required this.status,
    required this.totalAmount,
    required this.rooms,
  });

  final String bookingId;
  final String guestName;
  final String phone;
  final String email;
  final String expectedCheckin;
  final String expectedCheckout;
  final String status;
  final dynamic totalAmount;
  final List<String> rooms;

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      bookingId: json['bookingId']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      expectedCheckin: json['expectedCheckin']?.toString() ?? '',
      expectedCheckout: json['expectedCheckout']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: json['totalAmount'],
      rooms: (json['rooms'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool canCheckIn(String today) {
    final normalizedStatus = status.toUpperCase();
    return expectedCheckin.startsWith(today) &&
        (normalizedStatus == 'PENDING' ||
            normalizedStatus == 'CANCEL_REJECTED');
  }

  bool canCheckOut(String today) {
    final normalizedStatus = status.toUpperCase();
    return expectedCheckout.startsWith(today) &&
        (normalizedStatus == 'CHECKED_IN' ||
            normalizedStatus == 'CANCEL_REJECTED');
  }

  bool get canRequestCancel {
    final normalizedStatus = status.toUpperCase();
    return normalizedStatus == 'PENDING' || normalizedStatus == 'CHECKED_IN';
  }

  bool get hasReachedCheckinDeadline {
    final checkinDateTime = DateTime.tryParse(expectedCheckin);
    if (checkinDateTime == null) return false;
    return !DateTime.now().isBefore(checkinDateTime);
  }

  bool get canCancelCancelRequest => status.toUpperCase() == 'WAITING_APPROVAL';

  bool get isWaitingCancelApproval =>
      status.toUpperCase() == 'WAITING_APPROVAL';

  bool get isCancelRejected => status.toUpperCase() == 'CANCEL_REJECTED';

  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
}

class FeedbackModel {
  FeedbackModel({
    required this.feedbackId,
    required this.bookingId,
    required this.guestName,
    required this.phone,
    required this.bookingStatus,
    required this.rooms,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String feedbackId;
  final String bookingId;
  final String guestName;
  final String phone;
  final String bookingStatus;
  final List<String> rooms;
  final int rating;
  final String comment;
  final String createdAt;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bookingStatus: json['bookingStatus']?.toString() ?? '',
      rooms: (json['rooms'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class SubmitFeedbackPayload {
  SubmitFeedbackPayload({
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  final String bookingId;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'rating': rating,
    'comment': comment,
  };
}

class HotelServiceModel {
  HotelServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.price,
  });

  final String serviceId;
  final String serviceName;
  final String description;
  final double price;

  factory HotelServiceModel.fromJson(Map<String, dynamic> json) {
    return HotelServiceModel(
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CreateServiceOrderPayload {
  CreateServiceOrderPayload({required this.bookingId, required this.services});

  final String bookingId;
  final List<ServiceOrderLinePayload> services;

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'services': services.map((service) => service.toJson()).toList(),
  };
}

class ServiceOrderLinePayload {
  ServiceOrderLinePayload({required this.serviceId, required this.quantity});

  final String serviceId;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'quantity': quantity,
  };
}

class ServiceOrderModel {
  ServiceOrderModel({
    required this.orderId,
    required this.bookingId,
    required this.guestName,
    required this.phone,
    required this.status,
    required this.totalAmount,
    required this.orderedAt,
    required this.services,
  });

  final String orderId;
  final String bookingId;
  final String guestName;
  final String phone;
  final String status;
  final double totalAmount;
  final String orderedAt;
  final List<ServiceOrderLineModel> services;

  bool get canGuestCancel {
    final normalized = status.toUpperCase();
    return normalized == 'PENDING' || normalized == 'IN_PROGRESS';
  }

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderModel(
      orderId: json['orderId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      orderedAt: json['orderedAt']?.toString() ?? '',
      services: (json['services'] as List<dynamic>? ?? [])
          .map(
            (e) => ServiceOrderLineModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class ServiceOrderLineModel {
  ServiceOrderLineModel({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.priceAtOrder,
    required this.lineTotal,
  });

  final String serviceId;
  final String serviceName;
  final int quantity;
  final double priceAtOrder;
  final double lineTotal;

  factory ServiceOrderLineModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderLineModel(
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      priceAtOrder: (json['priceAtOrder'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RoomTypeModel {
  RoomTypeModel({
    required this.roomTypeId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imagePath,
  });

  final String roomTypeId;
  final String name;
  final String description;
  final double basePrice;
  final String imagePath;

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    final name = json['typeName']?.toString() ?? json['name']?.toString() ?? '';
    return RoomTypeModel(
      roomTypeId: json['roomTypeId']?.toString() ?? '',
      name: name,
      description: json['description']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      imagePath: _imageForRoomType(name),
    );
  }

  static String _imageForRoomType(String name) {
    final normalized = name.toLowerCase().trim();
    if (normalized.contains('suite')) {
      return 'asset/images_booking/noi-that-phong-ngu-cao-cap-01.jpg';
    }
    if (normalized.contains('deluxe')) {
      return 'asset/images_booking/khach-san-view-bien-da-nang-2.jpg';
    }
    if (normalized.contains('superior')) {
      return 'asset/images_booking/unnamed.jpg';
    }
    return 'asset/images_booking/thiet-ke-noi-that-khach-san-binh-dan-gay-an-tuong-du-khach.jpg';
  }
}

class RoomModel {
  RoomModel({
    required this.roomId,
    required this.roomTypeId,
    required this.roomNumber,
    required this.floor,
    required this.status,
    this.roomTypeName,
    this.description,
    this.basePrice,
    this.imagePath,
  });

  final String roomId;
  final String roomTypeId;
  final String roomNumber;
  final int floor;
  final String status;
  final String? roomTypeName;
  final String? description;
  final double? basePrice;
  final String? imagePath;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final roomTypeJson = json['roomType'];
    final roomTypeId = roomTypeJson is Map
        ? roomTypeJson['roomTypeId']?.toString() ?? ''
        : json['roomTypeId']?.toString() ?? '';
    final roomTypeName = roomTypeJson is Map
        ? roomTypeJson['typeName']?.toString() ??
              roomTypeJson['name']?.toString()
        : json['roomTypeName']?.toString() ??
              json['typeName']?.toString() ??
              json['name']?.toString();
    final description = roomTypeJson is Map
        ? roomTypeJson['description']?.toString()
        : json['description']?.toString();
    final basePrice = roomTypeJson is Map
        ? (roomTypeJson['basePrice'] as num?)?.toDouble()
        : (json['basePrice'] as num?)?.toDouble();

    return RoomModel(
      roomId: json['roomId']?.toString() ?? '',
      roomTypeId: roomTypeId,
      roomNumber:
          json['roomNumber']?.toString() ?? json['roomName']?.toString() ?? '',
      floor:
          (json['floor'] as num?)?.toInt() ??
          (json['floorNumber'] as num?)?.toInt() ??
          0,
      status: json['status']?.toString() ?? '',
      roomTypeName: roomTypeName,
      description: description,
      basePrice: basePrice,
      imagePath: roomTypeName == null
          ? null
          : RoomTypeModel._imageForRoomType(roomTypeName),
    );
  }
}
