# DATA DESIGN DOCUMENT — Hotel Management System (HMS)

> Tài liệu tổng hợp toàn bộ quy ước thiết kế dữ liệu đã thống nhất.
> Dùng làm reference cho Backend (JPA Entity) và Frontend (Model).
> Version 2.0 — 2026-07-16 (Technical Spec: Inventory, BOM, RBAC)

---

## 1. Quy ước sinh ID

### 1.1. Thực thể tĩnh (Master Data)

Format: `XXX-NNNNNNNN` (12 ký tự)

| Bảng | Prefix | Ví dụ |
|---|---|---|
| Roles | `ROL` | `ROL-00000001` |
| User | `USR` | `USR-00000001` |
| GuestProfile | `GST` | `GST-00000001` |
| EmployeeProfile | `EMP` | `EMP-00000001` |
| RoomType | `RTP` | `RTP-00000001` |
| Voucher | `VCH` | `VCH-00000001` |
| Service | `SRV` | `SRV-00000001` |
| InventoryItem | `INV` | `INV-00000001` |

**Ngoại lệ:**
- `Room.RoomId` — VARCHAR(5), số phòng vật lý (VD: `101`).
- `UserRole`, `Service_Inventory_Recipe` — PK composite, không có ID riêng.

### 1.2. Thực thể giao dịch (Transactional)

Format: `XXX-YYMMDDHHMMSS-HHHH` (20 ký tự)

| Bảng | Prefix | Ví dụ |
|---|---|---|
| Booking | `BOK` | `BOK-260714083000-A1B2` |
| RoomBooking | `RMB` | `RMB-260714083000-C3D4` |
| Payment | `PAY` | `PAY-260714083000-E5F6` |
| Surcharge | `SUR` | `SUR-260714083000-1A2B` |
| `Order` | `ORD` | `ORD-260714083000-9C0D` |
| MaintenanceRequest | `MNT` | `MNT-260714083000-3E4F` |
| AuditLog | `LOG` | `LOG-260714083000-5A6B` |
| Feedback | `FDB` | `FDB-260714083000-7C8D` |
| InventoryAdjustment | `ADJ` | `ADJ-260714083000-9E0F` |
| Expense | `EXP` | `EXP-260714083000-1A3C` |

---

## 2. Kiểu thời gian: DATETIME

Toàn bộ cột thời gian dùng `DATETIME`. Timezone: UTC+7.

---

## 3. Enum giá trị

### 3.1. Room.Status

`AVAILABLE` | `OCCUPIED` | `DIRTY` | `CLEANING` | `MAINTENANCE`

### 3.2. Booking.Status

`PENDING` | `CONFIRMED` | `CHECKED_IN` | `CHECKED_OUT` | `CANCELLED` | `NO_SHOW`

### 3.3. RoomBooking.Status

`RESERVED` | `CHECKED_IN` | `CHECKED_OUT` | `TRANSFERRED` | `CANCELLED`

### 3.4. Payment.Status

`PENDING` | `PARTIALLY_PAID` | `COMPLETED` | `FAILED` | `REFUNDED`

### 3.5. Payment.PaymentType

`DEPOSIT` | `FULL` | `PARTIAL` | `REFUND`

### 3.6. Payment.PaymentMethod

`CASH` | `CARD` | `VNPAY` | `BANK_TRANSFER`

### 3.7. MaintenanceRequest.Status

`PENDING` | `IN_PROGRESS` | `COMPLETED` | `CANCELLED`

### 3.8. Order.Status

`PENDING` | `IN_PROGRESS` | `COMPLETED` | `CANCELLED`

### 3.9. InventoryAdjustment.Type

| Giá trị | Ý nghĩa | Ai dùng | Sinh Expense? |
|---|---|---|---|
| `RESTOCK` | Nhập kho | Manager | ✅ Tự động |
| `CONSUME` | Xuất kho (bán hàng / nội bộ) | Service Staff / Auto | ❌ |
| `DAMAGE` | Xuất kho do hư hỏng | Service Staff, Housekeeper | ❌ |
| `RECONCILE` | Kiểm kê bù trừ chênh lệch | Manager | ❌ |

### 3.10. Expense.ExpenseType

| Giá trị | Ý nghĩa |
|---|---|
| `RESTOCK` | Chi phí nhập kho (tự động sinh khi Adjustment RESTOCK) |
| `OPERATIONAL` | Chi phí vận hành (điện, nước,...) — Manager tạo thủ công |

### 3.11. Các enum khác

| Bảng.Cột | Giá trị |
|---|---|
| GuestProfile.IdentityType | `CCCD`, `CMND`, `PASSPORT` |
| GuestProfile.Gender | `MALE`, `FEMALE`, `OTHER` |
| Surcharge.Type | `DAMAGE`, `LATE_CHECKOUT`, `EXTRA_SERVICE`, `OTHER` |
| AuditLog.ActionType | `INSERT`, `UPDATE`, `DELETE` |

---

## 4. Business Rules — Inventory

### 4.1. Nguyên tắc cốt lõi

- **InventoryItem** là Back-stage: chỉ chứa `UnitCost` (giá vốn), **không chứa giá bán**.
- **Service** là Front-stage: chứa `UnitPrice` (giá bán cho khách).
- `StockQuantity` **không được cập nhật trực tiếp** — mọi thay đổi phải qua `processInventoryAdjustment()`.

### 4.2. Luồng nhập kho (RESTOCK)

```
Manager tạo Adjustment (type=RESTOCK, quantity=+N)
  → StockQuantity += N
  → Tự động tạo Expense (type=RESTOCK, amount = UnitCost × N)
```

### 4.3. Luồng xuất kho tự động (Order COMPLETED)

```
Lễ tân tạo Order → Status = COMPLETED
  → Đọc Service_Inventory_Recipe để biết định mức
  → Gọi processInventoryAdjustment(type=CONSUME, quantity=-N)
  → StockQuantity -= N (cho phép âm)
```

### 4.4. Luồng xuất kho thủ công (CONSUME / DAMAGE)

```
Service Staff / Housekeeper tạo Adjustment (type=CONSUME hoặc DAMAGE)
  → StockQuantity -= N
  → KHÔNG sinh Expense
```

### 4.5. Kiểm kê (RECONCILE)

```
Manager tạo Adjustment (type=RECONCILE, quantity=delta)
  → StockQuantity = StockQuantity + delta (có thể âm hoặc dương)
  → KHÔNG sinh Expense
```

### 4.6. Negative Stock

- Hệ thống **cho phép tồn kho âm** (Soft Block) để không cản trở bán hàng.
- Manager dùng `RECONCILE` để cân bằng lại sau khi kiểm kê thực tế.

---

## 5. Phân quyền RBAC — Inventory

| Chức năng | OWNER | MANAGER | RECEPTIONIST | SERVICE_STAFF | HOUSEKEEPER |
|---|---|---|---|---|---|
| CRUD InventoryItem | ✅ | ✅ | ❌ 403 | ❌ | ❌ |
| Xem InventoryItem | ✅ | ✅ | ❌ 403 | ❌ | ❌ |
| Tạo Adjustment (RESTOCK) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Tạo Adjustment (RECONCILE) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Tạo Adjustment (CONSUME) | ✅ | ✅ | ❌ | ✅ | ❌ |
| Tạo Adjustment (DAMAGE) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Xem Expense | ✅ | ✅ | ❌ | ❌ | ❌ |
| Tạo Expense thủ công (OPERATIONAL) | ✅ | ✅ | ❌ | ❌ | ❌ |
| Xem Service (Front-stage) | ✅ | ✅ | ✅ | ✅ | ❌ |
| CRUD Service_Inventory_Recipe | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## 6. Soft Delete

| Nhóm bảng | Cơ chế |
|---|---|
| **Master** (RoomType, Service, InventoryItem, Voucher) | `IsActive = 0` |
| **Giao dịch** (Booking, Payment, Order, Adjustment, Expense) | Không xoá vật lý — dùng Status |
| **User** | `IsActive = 0` |

---

## 7. Xác thực

- Login bằng `Username` hoặc `Email`
- Hash password: BCrypt
- JWT chứa UserId + Roles

---

## 8. Tiền tệ

- VND, `DECIMAL(18,2)`, không đa tiền tệ.

---

## 9. Hệ thống phân quyền (Roles)

| RoleId | RoleName | Mô tả |
|---|---|---|
| `ROL-00000001` | OWNER | Chủ khách sạn — toàn quyền |
| `ROL-00000002` | MANAGER | Quản lý khách sạn |
| `ROL-00000003` | RECEPTIONIST | Lễ tân |
| `ROL-00000004` | SERVICE_STAFF | Nhân viên phục vụ |
| `ROL-00000005` | HOUSEKEEPER | Nhân viên buồng phòng |
| `ROL-00000006` | GUEST | Khách hàng |

---

*Version 2.0 — 2026-07-16*
