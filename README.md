# HMS — Hotel Management System

Hệ thống quản lý khách sạn đa nền tảng — Multi-Client Architecture.

- **Backend:** Java 26 + Spring Boot 4.1 + MySQL 8.0
- **Frontend:** 4 Flutter apps + 1 shared package (GetX + Dio)

---

## Cấu trúc dự án

```
hms/
├── hms_backend/                         # Spring Boot REST API
├── frontends/
│   ├── hms_shared/                      # Package dùng chung
│   ├── management_desktop/              # Desktop: Owner, Manager, Receptionist
│   ├── staff_mobile/                    # Mobile: Service Staff, Housekeeper
│   ├── booking_mobile/                  # Mobile: Guest (iOS/Android)
│   └── booking_web/                     # Web: Guest
├── HotelDB_Schema.sql
├── DATA_DESIGN.md
├── PROJECT_STRUCTURE.md
├── SCHEMA_SPEC.md
└── README.md
```

---

## Yêu cầu hệ thống

| Công cụ | Phiên bản |
|---|---|
| Java | 26+ |
| Gradle | 9.4.0+ |
| MySQL | 8.0+ |
| Flutter | 3.x+ |
| Dart | 3.12+ |

---

## Cài đặt & Chạy

### 1. Database

```sh
mysql -u root -p < HotelDB_Schema.sql
```

### 2. Backend

```sh
cd hms_backend

# Set biến môi trường
# Windows: set MYSQL_USERNAME=root && set MYSQL_PASSWORD=yourpass
# macOS/Linux: export MYSQL_USERNAME=root && export MYSQL_PASSWORD=yourpass

./gradlew bootRun        # macOS/Linux
gradlew.bat bootRun      # Windows
```

API docs: http://localhost:8080/swagger-ui.html

### 3. Frontend

```sh
cd frontends

# Cài dependency cho shared package
cd hms_shared && dart pub get && cd ..

# Chạy từng app
cd management_desktop && flutter pub get && flutter run -d windows
cd staff_mobile       && flutter pub get && flutter run
cd booking_mobile     && flutter pub get && flutter run
cd booking_web        && flutter pub get && flutter run -d chrome
```

---

## 4 App × 6 Role

| App | Nền tảng | Người dùng |
|---|---|---|
| **management_desktop** | Windows | Owner, Manager, Receptionist |
| **staff_mobile** | iOS/Android | Service Staff, Housekeeper |
| **booking_mobile** | iOS/Android | Guest |
| **booking_web** | Web | Guest |

### 6 Role

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
- VNPay integration, Gmail SMTP

**Frontend:**
- Flutter, GetX (state management + routing)
- Dio (HTTP client), flutter_secure_storage
- json_serializable (model generation)
