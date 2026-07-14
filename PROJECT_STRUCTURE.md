# PROJECT STRUCTURE — Hotel Management System (HMS)

> Bản thiết kế thi công — cập nhật 2026-07-14.
> Multi-Client Architecture: 1 Backend + 4 Frontends + 1 Shared Package.

---

## Tổng quan kiến trúc

```
hms/
├── hms_backend/                    # Spring Boot REST API (1 backend)
├── frontends/
│   ├── hms_shared/                 # Package dùng chung (models, API, auth)
│   ├── management_desktop/         # Desktop App — Owner, Manager, Receptionist
│   ├── staff_mobile/               # Mobile App — Service Staff, Housekeeper
│   ├── booking_mobile/             # Mobile App — Guest
│   └── booking_web/                # Web App — Guest
├── HotelDB_Schema.sql
├── DATA_DESIGN.md
├── PROJECT_STRUCTURE.md
├── SCHEMA_SPEC.md
└── README.md
```

---

## PHẦN 1: BACKEND - JAVA SPRING BOOT

**Dependencies:** Spring Web, Spring Data JPA, MySQL Driver, Spring Security, DevTools, Lombok, Validation, Springdoc OpenAPI, WebSockets.

### Package Structure

```
src/main/java/com/hotel/hms/
├── HmsApplication.java
├── config/
│   ├── OpenApiConfig.java
│   ├── SecurityConfig.java
│   ├── CorsConfig.java
│   └── WebSocketConfig.java
├── security/
│   ├── JwtTokenProvider.java
│   └── JwtAuthFilter.java
├── exception/
│   └── GlobalExceptionHandler.java
├── integration/
│   ├── vnpay/
│   └── mail/
└── modules/
    ├── authentication/           → entity/ dto/ repository/ service/ controller/
    ├── employee_management/      → entity/ dto/ repository/ service/ controller/
    ├── property_management/      → entity/ dto/ repository/ service/ controller/
    ├── booking_management/       → entity/ dto/ repository/ service/ controller/
    ├── catalogue_management/     → entity/ dto/ repository/ service/ controller/
    └── operation_analysis/       → entity/ dto/ repository/ service/ controller/
```

### Phân bổ Entity

| Module | Entity |
|---|---|
| **authentication** | `User`, `Roles`, `UserRole`, `GuestProfile` |
| **employee_management** | `EmployeeProfile` |
| **property_management** | `RoomType`, `Room`, `MaintenanceRequest` |
| **booking_management** | `Booking`, `RoomBooking`, `Voucher`, `Payment`, `Surcharge`, `Feedback` |
| **catalogue_management** | `Service`, `Order`, `ServiceOrder_InventoryItem`, `ServiceOrder_Service`, `InventoryItem`, `InventoryAdjustment`, `Expense` |
| **operation_analysis** | `AuditLog` |

---

## PHẦN 2: FRONTEND — Multi-Client Flutter

### 2.0. hms_shared (Dart Package)

```
frontends/hms_shared/lib/
├── auth/
│   ├── token_storage.dart        # Lưu/đọc JWT từ flutter_secure_storage
│   ├── auth_interceptor.dart     # Dio interceptor — gắn token, refresh 401
│   ├── auth_provider.dart        # Gọi API login, register, logout
│   ├── auth_service.dart         # GetX Service — session toàn cục
│   ├── auth_model.dart           # LoginRequest, LoginResponse, TokenPayload
│   └── role_guard.dart           # GetMiddleware chặn route sai role
├── models/                       # Dart models (UserModel, RoomModel, ...)
├── providers/                    # Dio API providers (RoomProvider, ...)
├── constants/                    # api_constants, app_colors
└── utils/                        # date_formatter, currency_formatter
```

### 2.1. management_desktop — Owner, Manager, Receptionist

```
frontends/management_desktop/lib/
├── main.dart
└── modules/
    ├── dashboard/                → view/ viewmodel/
    ├── employee_management/      → view/ viewmodel/
    ├── property_management/      → view/ viewmodel/
    ├── booking_management/       → view/ viewmodel/
    ├── catalogue_management/     → view/ viewmodel/
    └── operation_analysis/       → view/ viewmodel/
```

### 2.2. staff_mobile — Service Staff, Housekeeper

```
frontends/staff_mobile/lib/
├── main.dart
└── modules/
    ├── task/                     → view/ viewmodel/    (dọn phòng, order)
    └── property/                 → view/ viewmodel/    (báo maintenance)
```

### 2.3. booking_mobile — Guest (iOS/Android)

```
frontends/booking_mobile/lib/
├── main.dart
└── modules/
    ├── home/                     → view/ viewmodel/    (tìm kiếm phòng)
    ├── booking/                  → view/ viewmodel/    (đặt phòng, thanh toán)
    └── profile/                  → view/ viewmodel/    (lịch sử, feedback)
```

### 2.4. booking_web — Guest (Web)

```
frontends/booking_web/lib/
├── main.dart
└── modules/
    ├── home/                     → view/ viewmodel/
    ├── booking/                  → view/ viewmodel/
    └── profile/                  → view/ viewmodel/
```

---

## Ma trận App × Role

| App | OWNER | MANAGER | RECEPTIONIST | SERVICE_STAFF | HOUSEKEEPER | GUEST |
|---|---|---|---|---|---|---|
| management_desktop | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| staff_mobile | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| booking_mobile | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| booking_web | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## PHẦN 3: DATABASE

- **File:** `HotelDB_Schema.sql` — 22 bảng + seed data (6 roles, 4 room types)
- **ID:** Static `XXX-NNNNNNNN` (12) / Transactional `XXX-YYMMDDHHMMSS-HHHH` (20)
- **Time:** `DATETIME`
- **Tài liệu:** `DATA_DESIGN.md`

---

## Tài liệu

| File | Nội dung |
|---|---|
| `README.md` | Hướng dẫn cài đặt & chạy |
| `PROJECT_STRUCTURE.md` | File này — cấu trúc dự án |
| `DATA_DESIGN.md` | Quy ước dữ liệu (ID, enum, role, soft delete) |
| `SCHEMA_SPEC.md` | Spec gốc 22 bảng |
| `HotelDB_Schema.sql` | DDL SQL + seed data |
