# FPT Golden HMS — Architecture & Design Notes

## 1. Front-stage vs Back-stage Separation

### InventoryItem (Back-stage — Warehouse)
- Represents physical goods in storage
- **ONLY contains `unitCost`** (import cost / giá vốn)
- **NEVER add `unitPrice`** (that's for services)
- Examples: soap bars, minibar drinks, cleaning supplies

### Service (Front-stage — Guest-facing)
- Represents items/services sold to guests
- **MUST contain `unitPrice`** (selling price / giá bán)
- Examples: Minibar consumption, Laundry, Room Service meals

### BOM Mapping (Service_Inventory_Recipe)
- Junction table linking Service ↔ InventoryItem
- Columns: `RecipeId`, `ServiceId`, `InventoryItemId`, `QuantityRequired`
- When a service is sold → auto-consume the mapped inventory items
- Purpose: e.g., selling "Minibar Coke" consumes 1 "Coke Can" from inventory

## 2. Transactional Entities

### InventoryAdjustment
Tracks all stock changes:
| Column | Type | Notes |
|---|---|---|
| AdjustmentId | VARCHAR(20) | PK |
| ItemId | FK → InventoryItem | |
| EmployeeId | FK → EmployeeProfile | |
| Quantity | INT | Absolute value |
| Type | ENUM | See below |
| Reason | VARCHAR(255) | |
| CreatedAt | DATETIME | |

**Adjustment Types:**
| Type | Description | Who Can Trigger |
|---|---|---|
| `RESTOCK` | Nhập kho | OWNER, MANAGER |
| `CONSUME` | Tiêu hao nội bộ | MANAGER, SERVICE_STAFF |
| `DAMAGE` | Hư hỏng | MANAGER, SERVICE_STAFF, HOUSEKEEPER |
| `RECONCILE` | Kiểm kê điều chỉnh | OWNER, MANAGER |
| `LOSS` | Thất thoát (kiểm kê phát hiện thiếu) | OWNER, MANAGER |
| `AUTO_SELL` | Bán tự động (từ Order) | System only |

### Expense
Tracks financial outflows:
| Column | Type | Notes |
|---|---|---|
| ExpenseId | VARCHAR(20) | PK |
| AdjustmentId | FK → InventoryAdjustment | **NULLABLE** (0..1) |
| ExpenseType | ENUM | `RESTOCK`, `OPERATIONAL` |
| Amount | DECIMAL(18,2) | |
| Description | VARCHAR(255) | |
| CreatedAt | DATETIME | |

- **Auto-generated** when AdjustmentType == `RESTOCK`
- **Manual** standalone expenses for operational costs (electricity, repairs, etc.)

## 3. Business Logic

### Stock Modification Rule
🚫 **FORBIDDEN**: Direct `item.setStockQuantity(x)` — NEVER use setters
✅ **REQUIRED**: All changes via `processInventoryAdjustment()`

### Auto-Deduction Flow
1. Guest Order → `COMPLETED`
2. System reads `Service_Inventory_Recipe` for the ordered services
3. Triggers `processInventoryAdjustment(Type: AUTO_SELL)` for each mapped item
4. **Soft Block**: Negative stock is ALLOWED (operations continue)
5. Discrepancies fixed later via inventory reconciliation

## 4. RBAC — API Endpoint Security

### OWNER (Chủ khách sạn — Overseer)
- Theo dõi thống kê vận hành & lợi nhuận
- Set chính sách giá (Service unitPrice) và Voucher
- **Không** tham gia vận hành hàng ngày

| Endpoint | Access |
|---|---|
| `PATCH /api/services/{id}/unit-price` | ✅ **EXCLUSIVE** |
### MANAGER (Quản lý tại chỗ — On-site Overseer)
- Toàn quyền vận hành: CRUD Inventory, RESTOCK, kiểm kê, tạo Expense
- **Không** được đổi giá dịch vụ, **không** xem một số thống kê lợi nhuận

| Endpoint | Access |
|---|---|
| `CRUD /api/inventory/items` | ✅ Full |
| `POST /api/inventory/adjustments` (RESTOCK, RECONCILE, LOSS) | ✅ |
| `POST /api/expenses` (manual) | ✅ |
| `PATCH /api/services/{id}/unit-price` | ❌ No pricing power |
| `CRUD /api/inventory/items` | ✅ Full |
| `POST /api/inventory/adjustments` (RESTOCK, RECONCILE, LOSS) | ✅ |
| `POST /api/expenses` (manual) | ✅ |
| `PATCH /api/services/{id}/unit-price` | ❌ No pricing power |

### RECEPTIONIST
| Endpoint | Access |
|---|---|
| `GET /api/services` | ✅ Read catalogue |
| `GET /api/inventory/**` | ❌ 403 Forbidden (hide backend costs) |

### SERVICE_STAFF / HOUSEKEEPER
| Endpoint | Access |
|---|---|
| `POST /api/inventory/adjustments` | ✅ Only `CONSUME`, `DAMAGE` |
| Others | ❌ |

## 5. Entity Field Constraints

| Entity | Field | Constraint |
|---|---|---|
| InventoryItem | unitCost | ✅ Present — import cost only |
| InventoryItem | unitPrice | ❌ MUST NOT exist |
| Service | unitPrice | ✅ Present — field renamed to `unitPrice` |
| Expense | adjustment | NULLABLE (0..1) |
| Expense | expenseType | ENUM: RESTOCK, OPERATIONAL |

## 6. ID Format
- **Static**: `XXX-NNNNNNNN` (VARCHAR 12)
- **Transactional**: `XXX-YYMMDDHHMMSS-HHHH` (VARCHAR 20)
