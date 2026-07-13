# HMS — Hotel Management System

Hệ thống quản lý khách sạn đa nền tảng.

- **Backend:** Java 26 + Spring Boot 4.1 + MySQL 8.0
- **Frontend:** Flutter 3.x + GetX + Dio

---

## Cấu trúc dự án

```
hms/
├── hms_backend/          # Spring Boot REST API
├── hms_frontend/         # Flutter App (Android, iOS, Web, Desktop)
├── HotelDB_Schema.sql    # Database schema + seed data
├── DATA_DESIGN.md        # Quy ước thiết kế dữ liệu (ID, enum, role, soft delete)
├── PROJECT_STRUCTURE.md  # Cấu trúc code & phân bổ module
└── SCHEMA_SPEC.md        # Spec gốc 22 bảng từ BA
```

---

## Yêu cầu hệ thống

| Công cụ | Phiên bản |
|---|---|
| Java | 26+ |
| MySQL | 8.0+ |
| Flutter | 3.x+ |
| Dart | 3.12+ |

---

## Cài đặt & Chạy

### 1. Database

```sh
mysql -u root -p < HotelDB_Schema.sql
```

Cấu hình biến môi trường trước khi chạy.

### 2. Backend

```sh
cd hms_backend
./gradlew bootRun        # macOS/Linux
gradlew.bat bootRun      # Windows
```

API docs tại: http://localhost:8080/swagger-ui.html

### 3. Frontend

```sh
cd hms_frontend
flutter pub get
flutter run
```

---

## 6 Module nghiệp vụ

| Module | Chức năng |
|---|---|
| **authentication** | Đăng nhập, đăng ký, JWT, phân quyền (6 roles) |
| **employee_management** | Quản lý nhân viên |
| **property_management** | Quản lý phòng, loại phòng, bảo trì |
| **booking_management** | Đặt phòng, thanh toán, voucher, feedback |
| **catalogue_management** | Dịch vụ, order, kho vật tư |
| **operation_analysis** | Audit log, báo cáo |

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

## Tech Stack

**Backend:**
- Spring Boot 4.1, Spring Security, Spring Data JPA
- JWT Authentication, BCrypt
- Swagger/OpenAPI, WebSocket

**Frontend:**
- Flutter, GetX (state management + routing)
- Dio (HTTP client), flutter_secure_storage
- json_serializable (model generation)
