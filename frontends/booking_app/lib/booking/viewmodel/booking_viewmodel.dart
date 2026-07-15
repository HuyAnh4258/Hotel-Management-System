import 'package:dio/dio.dart';

class BookingApi {
  BookingApi._();

  static const String baseUrl = 'http://10.0.2.2:8080/api/booking';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<HomepageData> getHomepage() async {
    final response = await _dio.get('/homepage');
    return HomepageData.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<List<BookingSummary>> getBookings({String? date}) async {
    final response = await _dio.get(
      '',
      queryParameters: date == null ? null : {'date': date},
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (e) => BookingSummary.fromJson(Map<String, dynamic>.from(e as Map)),
        )
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

  static Future<void> createBooking(CreateBookingPayload payload) async {
    await _dio.post('', data: payload.toJson());
  }
}

class CreateBookingPayload {
  CreateBookingPayload({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.roomTypeId,
    required this.roomId,
    required this.expectedCheckin,
    required this.expectedCheckout,
  });

  final String fullName;
  final String phone;
  final String email;
  final String roomTypeId;
  final String roomId;
  final String expectedCheckin;
  final String expectedCheckout;

  Map<String, dynamic> toJson() => {
    'guestName': fullName,
    'phone': phone,
    'email': email,
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
    required this.expectedCheckin,
    required this.expectedCheckout,
    required this.status,
    required this.totalAmount,
    required this.rooms,
  });

  final String bookingId;
  final String guestName;
  final String phone;
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
      expectedCheckin: json['expectedCheckin']?.toString() ?? '',
      expectedCheckout: json['expectedCheckout']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: json['totalAmount'],
      rooms: (json['rooms'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool canCheckIn(String today) =>
      expectedCheckin.startsWith(today) && status.toUpperCase() == 'PENDING';

  bool canCheckOut(String today) =>
      expectedCheckout.startsWith(today) &&
      status.toUpperCase() == 'CHECKED_IN';
}

class RoomTypeModel {
  RoomTypeModel({
    required this.roomTypeId,
    required this.name,
    required this.description,
    required this.basePrice,
  });

  final String roomTypeId;
  final String name;
  final String description;
  final double basePrice;

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      roomTypeId: json['roomTypeId']?.toString() ?? '',
      name: json['typeName']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RoomModel {
  RoomModel({
    required this.roomId,
    required this.roomTypeId,
    required this.roomNumber,
    required this.floor,
    required this.status,
  });

  final String roomId;
  final String roomTypeId;
  final String roomNumber;
  final int floor;
  final String status;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final roomTypeJson = json['roomType'];
    final roomTypeId = roomTypeJson is Map
        ? roomTypeJson['roomTypeId']?.toString() ?? ''
        : json['roomTypeId']?.toString() ?? '';

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
    );
  }
}
