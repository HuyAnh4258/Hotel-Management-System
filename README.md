# HMS — Hotel Management System

Hệ thống quản lý khách sạn đa nền tảng — Multi-Client Architecture.

- **Backend:** Java 26 + Spring Boot 4.1 + MySQL 8.0
- **Frontend:** 2 Flutter apps + 1 shared package (GetX + Dio)

---

## Cấu trúc dự án

```
hms/
├── hms_backend/                    # Spring Boot REST API
├── frontends/
│   ├── hms_shared/                 # Package dùng chung (models, API, auth)
│   ├── management_app/             # Management App (5 role, build Mobile + Desktop)
│   └── booking_app/                # Booking App (Guest, build Mobile + Web)
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

./gradlew bootRun
```

API docs: http://localhost:8080/swagger-ui.html

### 3. Frontend

```sh
cd frontends/hms_shared && dart pub get && cd ..

# Management App — Mobile hoặc Desktop (phân quyền runtime)
cd management_app && flutter pub get
flutter run -d windows     # Desktop
flutter run -d android     # Mobile

# Booking App — Mobile hoặc Web
cd booking_app && flutter pub get
flutter run -d android     # Mobile
flutter run -d chrome      # Web
```

---

## 2 App × 6 Role

```
management_app                    booking_app
┌─────────────────────┐          ┌──────────────┐
│ OWNER                │          │              │
│ MANAGER              │          │    GUEST     │
│ RECEPTIONIST         │          │              │
│ SERVICE_STAFF        │          │  Mobile      │
│ HOUSEKEEPER          │          │  Web         │
│                      │          └──────────────┘
│ Mobile + Desktop     │
└─────────────────────┘
```

Phân quyền bằng `role_guard` middleware — cùng 1 app, khác role thấy khác giao diện.

---

## Tech Stack

**Backend:** Spring Boot 4.1, Spring Security, Spring Data JPA, JWT, BCrypt, Swagger, WebSocket, VNPay, Gmail SMTP

**Frontend:** Flutter, GetX, Dio, flutter_secure_storage, json_serializable
