# PROJECT STRUCTURE — Hotel Management System (HMS)

> Bản thiết kế thi công — cập nhật 2026-07-14.
> 1 Backend + 2 Flutter Apps + 1 Shared Package.

---

## Tổng quan

```
hms/
├── hms_backend/                    # Spring Boot REST API
├── frontends/
│   ├── hms_shared/                 # Package dùng chung
│   ├── management_app/             # Mobile + Desktop (5 role, phân quyền runtime)
│   └── booking_app/                # Mobile + Web (Guest)
├── HotelDB_Schema.sql
├── DATA_DESIGN.md
├── PROJECT_STRUCTURE.md
├── SCHEMA_SPEC.md
└── README.md
```

---

## PHẦN 1: BACKEND

```
src/main/java/com/hotel/hms/
├── HmsApplication.java
├── config/            OpenApiConfig, SecurityConfig, CorsConfig, WebSocketConfig
├── security/          JwtTokenProvider, JwtAuthFilter
├── exception/         GlobalExceptionHandler
├── integration/
│   ├── vnpay/
│   └── mail/
└── modules/
    ├── authentication/           → User, Roles, UserRole, GuestProfile
    ├── employee_management/      → EmployeeProfile
    ├── property_management/      → RoomType, Room, MaintenanceRequest
    ├── booking_management/       → Booking, RoomBooking, Voucher, Payment, Surcharge, Feedback
    ├── catalogue_management/     → Service, Order, SO_InventoryItem, SO_Service, InventoryItem, InventoryAdjustment, Expense
    └── operation_analysis/       → AuditLog
```

---

## PHẦN 2: FRONTEND

### 2.0. hms_shared

```
lib/
├── auth/              token_storage, auth_interceptor, auth_provider, auth_service, auth_model, role_guard
├── models/            Dart models
├── providers/         Dio API providers
├── constants/         api_constants, app_colors
├── utils/             date_formatter, currency_formatter
└── widgets/           Widget dùng chung 2 app (HmsButton, HmsTextField, LoadingOverlay)
```

### 2.1. management_app — 5 Role (Mobile + Desktop)

```
lib/
├── widgets/                       # Widget riêng app
└── modules/
    ├── auth/                       → view/ viewmodel/ widgets/
    ├── dashboard/                  → view/ viewmodel/ widgets/
    ├── employee_management/        → view/ viewmodel/ widgets/
    ├── property_management/        → view/ viewmodel/ widgets/
    ├── booking_management/         → view/ viewmodel/ widgets/
    ├── catalogue_management/       → view/ viewmodel/ widgets/
    ├── operation_analysis/         → view/ viewmodel/ widgets/
    ├── task/                       → view/ viewmodel/ widgets/
    └── maintenance/                → view/ viewmodel/ widgets/
```

### 2.2. booking_app — Guest (Mobile + Web)

```
lib/
├── widgets/                       # Widget riêng app
└── modules/
    ├── auth/                       → view/ viewmodel/ widgets/
    ├── home/                       → view/ viewmodel/ widgets/
    ├── booking/                    → view/ viewmodel/ widgets/
    └── profile/                    → view/ viewmodel/ widgets/
```

---

## Ma trận App × Role

| App | OWNER | MANAGER | RECEPTIONIST | SERVICE_STAFF | HOUSEKEEPER | GUEST |
|---|---|---|---|---|---|---|
| management_app | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| booking_app | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## PHẦN 3: DATABASE

- **File:** `HotelDB_Schema.sql` — 22 bảng + seed data
- **ID:** Static `XXX-NNNNNNNN` / Transactional `XXX-YYMMDDHHMMSS-HHHH`
- **Time:** `DATETIME`
- **Chi tiết:** `DATA_DESIGN.md`
