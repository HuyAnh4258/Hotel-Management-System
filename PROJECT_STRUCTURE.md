# PROJECT STRUCTURE — Hotel Management System (HMS)

> Bản thiết kế thi công (Boilerplate Blueprint) — cập nhật 2026-07-14.
> Bám sát sườn này để khởi tạo project, chia việc cho team và bắt đầu code.

---

## PHẦN 1: BACKEND - JAVA SPRING BOOT

**Dependencies:** Spring Web, Spring Data JPA, MySQL Driver, Spring Security, DevTools, Lombok, Validation, Springdoc OpenAPI (Swagger), WebSockets.

### Cấu trúc thư mục

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

### Phân bổ Entity theo Module

| Module | Entity |
|---|---|
| **authentication** | `User`, `Roles`, `UserRole`, `GuestProfile` |
| **employee_management** | `EmployeeProfile` |
| **property_management** | `RoomType`, `Room`, `MaintenanceRequest` |
| **booking_management** | `Booking`, `RoomBooking`, `Voucher`, `Payment`, `Surcharge`, `Feedback` |
| **catalogue_management** | `Service`, `Order`, `ServiceOrder_InventoryItem`, `ServiceOrder_Service`, `InventoryItem`, `InventoryAdjustment`, `Expense` |
| **operation_analysis** | `AuditLog` (mở rộng: report views) |

### 6 Role người dùng

| Role | Mô tả |
|---|---|
| OWNER | Chủ khách sạn — toàn quyền |
| MANAGER | Quản lý — vận hành, báo cáo |
| RECEPTIONIST | Lễ tân — check-in/out, booking, payment |
| SERVICE_STAFF | Nhân viên phục vụ — xử lý Order |
| HOUSEKEEPER | Nhân viên buồng phòng — dọn phòng, bảo trì |
| GUEST | Khách — đặt phòng, gọi dịch vụ |

---

## PHẦN 2: FRONTEND - FLUTTER (GetX + Dio)

**Dependencies:** `get`, `dio`, `flutter_secure_storage`.

### Cấu trúc thư mục

```
lib/
├── main.dart
├── core/
│   ├── constants/                 # api_constants, app_colors, app_strings
│   ├── network/
│   │   ├── dio_client.dart        # Khởi tạo Dio với baseUrl, timeout
│   │   └── auth_interceptor.dart  # Tự động gắn JWT vào header
│   └── utils/                     # date_formatter, currency_formatter
├── data/
│   ├── models/                    # Map JSON → Dart object
│   └── providers/                 # Gọi API bằng Dio
├── routes/
│   └── app_pages.dart
└── modules/
    ├── auth/                      → view/ viewmodel/
    ├── booking_management/        → view/ viewmodel/
    ├── catalogue_management/      → view/ viewmodel/
    ├── property_management/       → view/ viewmodel/
    ├── employee_management/       → view/ viewmodel/
    └── operation_analysis/        → view/ viewmodel/
```

---

## PHẦN 3: DATABASE - MySQL 8.0+

- **File:** `HotelDB_Schema.sql` — 22 bảng + seed data (6 roles, 4 room types)
- **ID format:** Static `XXX-NNNNNNNN` (12) / Transactional `XXX-YYMMDDHHMMSS-HHHH` (20)
- **Thời gian:** `DATETIME` (không giới hạn 2038)
- **Soft delete:** `IsActive` cho master, `Status` enum cho giao dịch
- **Tài liệu:** `DATA_DESIGN.md` (quy ước ID, enum, ma trận quyền)

---

## Tài liệu liên quan

| File | Nội dung |
|---|---|
| `PROJECT_STRUCTURE.md` | File này — cấu trúc dự án |
| `DATA_DESIGN.md` | Quy ước thiết kế dữ liệu (ID, enum, role, soft delete) |
| `SCHEMA_SPEC.md` | Spec gốc từ BA (22 bảng) |
| `HotelDB_Schema.sql` | DDL SQL hoàn chỉnh + seed data |
