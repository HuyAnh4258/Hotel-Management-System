# DATA DESIGN DOCUMENT — Hotel Management System (HMS)

> Tài liệu tổng hợp toàn bộ quy ước thiết kế dữ liệu đã thống nhất.
> Dùng làm reference cho Backend (JPA Entity) và Frontend (Model).

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
- `Room.RoomId` — VARCHAR(5), là số phòng vật lý (VD: `101`, `P201`).
- `UserRole` — PK composite (UserId, RoleId), không có ID riêng.

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

Toàn bộ cột thời gian dùng `DATETIME` (không giới hạn 2038 như TIMESTAMP).
Timezone: UTC+7 (Việt Nam). Backend chịu trách nhiệm convert.

---

## 3. Enum giá trị (Status)

### 3.1. Room.Status

| Giá trị | Ý nghĩa |
|---|---|
| `AVAILABLE` | Trống, sạch, sẵn sàng bán |
| `OCCUPIED` | Đang có khách |
| `DIRTY` | Khách vừa checkout, chờ dọn |
| `CLEANING` | Đang dọn dẹp |
| `MAINTENANCE` | Đang bảo trì, không bán được |

Luồng: `AVAILABLE → OCCUPIED → DIRTY → CLEANING → AVAILABLE`; bất kỳ → `MAINTENANCE → AVAILABLE`.

### 3.2. Booking.Status

| Giá trị | Ý nghĩa |
|---|---|
| `PENDING` | Vừa đặt, chưa cọc |
| `CONFIRMED` | Đã cọc / xác nhận |
| `CHECKED_IN` | Đã nhận phòng |
| `CHECKED_OUT` | Đã trả phòng |
| `CANCELLED` | Đã huỷ |
| `NO_SHOW` | Không đến |

### 3.3. RoomBooking.Status

| Giá trị | Ý nghĩa |
|---|---|
| `RESERVED` | Đã giữ chỗ |
| `CHECKED_IN` | Đã nhận phòng |
| `CHECKED_OUT` | Đã trả phòng |
| `TRANSFERRED` | Đã đổi phòng |
| `CANCELLED` | Đã huỷ |

### 3.4. Payment.Status

| Giá trị | Ý nghĩa |
|---|---|
| `PENDING` | Chờ thanh toán |
| `PARTIALLY_PAID` | Đã trả 1 phần |
| `COMPLETED` | Đã trả đủ |
| `FAILED` | Thất bại |
| `REFUNDED` | Đã hoàn tiền |

### 3.5. Payment.PaymentType

`DEPOSIT` | `FULL` | `PARTIAL` | `REFUND`

### 3.6. Payment.PaymentMethod

`CASH` | `CARD` | `VNPAY` | `BANK_TRANSFER`

### 3.7. MaintenanceRequest.Status

`PENDING` | `IN_PROGRESS` | `COMPLETED` | `CANCELLED`

### 3.8. Order.Status

`PENDING` | `IN_PROGRESS` | `COMPLETED` | `CANCELLED`

### 3.9. Các enum khác

| Bảng.Cột | Giá trị |
|---|---|
| GuestProfile.IdentityType | `CCCD`, `CMND`, `PASSPORT` |
| GuestProfile.Gender | `MALE`, `FEMALE`, `OTHER` |
| Surcharge.Type | `DAMAGE`, `LATE_CHECKOUT`, `EXTRA_SERVICE`, `OTHER` |
| InventoryAdjustment.Type | `IMPORT`, `EXPORT` |
| AuditLog.ActionType | `INSERT`, `UPDATE`, `DELETE` |

---

## 4. Soft Delete

| Nhóm bảng | Cơ chế |
|---|---|
| **Master** (RoomType, Service, InventoryItem, Voucher) | `IsActive = 0` → ẩn khỏi UI, dữ liệu cũ vẫn tham chiếu được |
| **Giao dịch** (Booking, Payment, Order, ...) | **Không cần** IsDeleted. Status (`CANCELLED`, `REFUNDED`) đã thể hiện. Không bao giờ xoá vật lý. |
| **User** | `IsActive = 0` → khoá tài khoản. Không xoá. |

---

## 5. Xác thực

- Login bằng `Username` hoặc `Email` (nếu input chứa `@` → query Email, ngược lại query Username)
- Hash password: BCrypt
- JWT chứa UserId + Roles

---

## 6. Tiền tệ

- VND, `DECIMAL(18,2)`, không đa tiền tệ.

---

## 7. Hệ thống phân quyền (Roles)

| RoleId | RoleName | Mô tả |
|---|---|---|
| `ROL-00000001` | OWNER | Chủ khách sạn — toàn quyền hệ thống |
| `ROL-00000002` | MANAGER | Quản lý khách sạn — quản lý nhân viên, báo cáo |
| `ROL-00000003` | RECEPTIONIST | Lễ tân — check-in/out, đặt phòng, thanh toán |
| `ROL-00000004` | SERVICE_STAFF | Nhân viên phục vụ — xử lý Order dịch vụ |
| `ROL-00000005` | HOUSEKEEPER | Nhân viên buồng phòng — dọn phòng, báo cáo trạng thái |
| `ROL-00000006` | GUEST | Khách hàng — đặt phòng, gọi dịch vụ, feedback |

### Ma trận quyền theo Role

| Chức năng | OWNER | MANAGER | RECEPTIONIST | SERVICE_STAFF | HOUSEKEEPER | GUEST |
|---|---|---|---|---|---|---|
| Quản lý User/Role | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Xem báo cáo doanh thu | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Quản lý phòng (CRUD) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Quản lý RoomType, Service, Voucher | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Check-in / Check-out | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Tạo Booking | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| Xử lý thanh toán | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Tạo Order dịch vụ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Xử lý Order (IN_PROGRESS → COMPLETED) | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Cập nhật trạng thái phòng (dọn dẹp) | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| Tạo MaintenanceRequest | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| Xem lịch sử Booking của bản thân | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gửi Feedback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Quản lý Inventory | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

---

*Version 1.1 — 2026-07-14*
