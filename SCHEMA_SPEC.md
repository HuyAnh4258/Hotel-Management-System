Hãy đóng vai là một Database Architect chuyên nghiệp. Dựa vào bản thiết kế dữ liệu (Schema Design) chi tiết dưới đây, hãy viết cho tôi toàn bộ câu lệnh SQL DDL (CREATE TABLE) để khởi tạo cơ sở dữ liệu trên MySQL (hoặc tạo các class Entity cho Java Spring Boot JPA).

QUY ƯỚC KÝ HIỆU TRONG THIẾT KẾ:
- [PK]: Primary Key (Khóa chính)
- [FK]: Foreign Key (Khóa ngoại)
- [U]: Unique (Ràng buộc duy nhất)
- [N]: Nullable (Cho phép giá trị NULL. Nếu không có ký hiệu này, mặc định bắt buộc là NOT NULL)

DANH SÁCH THỰC THỂ VÀ THUỘC TÍNH:

1. Bảng `Roles`
- RoleId: varchar(12) [PK]
- RoleName: varchar(50) [U]
- Description: varchar(255) [N]

2. Bảng `User`
- UserId: varchar(12) [PK]
- Username: varchar(50) [U]
- Email: varchar(100) [U]
- HashedPassword: varchar(255)
- IsActive: bit
- CreatedAt: timestamp

3. Bảng `UserRole` (Bảng trung gian)
- UserId: varchar(12) [PK, FK tham chiếu đến User.UserId]
- RoleId: varchar(12) [PK, FK tham chiếu đến Roles.RoleId]

4. Bảng `GuestProfile`
- GuestId: varchar(12) [PK]
- UserId: varchar(12) [FK tham chiếu đến User.UserId]
- FullName: varchar(100)
- Phone: varchar(10) [U]
- IdentityNumber: varchar(20) [N, U] 
- IdentityType: varchar(20) [N] 
- DateOfBirth: date [N]
- Gender: varchar(10) [N]
- Nationality: varchar(50) [N]
- Address: varchar(255) [N]

5. Bảng `EmployeeProfile`
- UserId: varchar(12) [PK, FK tham chiếu đến User.UserId]
- EmployeeId: varchar(12) [U]
- FullName: varchar(100)
- Phone: varchar(10) [U]
- Salary: decimal(18, 2) [N]
- HireDate: date

6. Bảng `AuditLog`
- LogId: varchar(12) [PK]
- UserId: varchar(12) [FK tham chiếu đến User.UserId]
- ActionType: varchar(50)
- TableName: varchar(100)
- OldValues: TEXT [N]
- NewValues: TEXT [N]
- Timestamp: timestamp [N]

7. Bảng `RoomType`
- RoomTypeId: varchar(12) [PK]
- TypeName: varchar(50) [U]
- Description: varchar(255) [N]
- BasePrice: decimal(18, 2)
- MaxOccupancy: integer(10)
- isActive: bit

8. Bảng `Room`
- RoomId: varchar(5) [PK]
- RoomTypeId: varchar(12) [FK tham chiếu đến RoomType.RoomTypeId]
- RoomName: varchar(50) [U]
- FloorNumber: integer(10)
- Status: varchar(20)
- Description: varchar(255) [N]
- isActive: bit

9. Bảng `MaintenanceRequest`
- RequestId: varchar(12) [PK]
- ReporterId: varchar(12) [FK tham chiếu đến EmployeeProfile.UserId]
- RoomId: varchar(5) [FK tham chiếu đến Room.RoomId]
- Description: varchar(500)
- Status: varchar(20)
- CreatedAt: timestamp
- UpdatedAt: timestamp [N]

10. Bảng `Voucher`
- VoucherId: varchar(12) [PK]
- VoucherCode: varchar(50) [U]
- DiscountPercent: decimal(5, 2) [N]
- MaxDiscountAmount: decimal(18, 2) [N]
- DiscountAmount: decimal(18, 2) [N]
- MinBookingValue: decimal(18, 2) [N]
- ExpiryTime: timestamp
- isActive: bit

11. Bảng `Booking`
- BookingId: varchar(12) [PK]
- GuestId: varchar(12) [FK tham chiếu đến GuestProfile.GuestId]
- VoucherId: varchar(12) [FK tham chiếu đến Voucher.VoucherId] [N]
- ExpectedCheckin: timestamp
- ExpectedCheckOut: timestamp
- Status: varchar(20)
- TotalAmount: decimal(18, 2)
- CreatedAt: timestamp

12. Bảng `RoomBooking`
- RoomBookingId: varchar(12) [PK]
- RoomId: varchar(5) [FK tham chiếu đến Room.RoomId]
- BookingId: varchar(12) [FK tham chiếu đến Booking.BookingId]
- PriceAtBooking: decimal(18, 2)
- ActualCheckin: timestamp [N]
- ActualCheckout: timestamp [N]
- Status: varchar(20)
- TransferredTo: varchar(12) [N] [Tự tham chiếu]

13. Bảng `Surcharge`
- SurchargeId: varchar(12) [PK]
- RoomBookingId: varchar(12) [FK tham chiếu đến RoomBooking.RoomBookingId]
- Amount: decimal(18, 2)
- Reason: varchar(255)
- Type: varchar(20)
- CreatedBy: varchar(12)
- CreatedAt: timestamp

14. Bảng `Payment`
- PaymentId: varchar(12) [PK]
- BookingId: varchar(12) [FK tham chiếu đến Booking.BookingId]
- Amount: decimal(18, 2)
- PaymentType: varchar(20)
- PaymentMethod: varchar(50)
- PaidAt: timestamp
- Status: varchar(20)
- TransactionRef: varchar(255) [N]

15. Bảng `Feedback`
- FeedbackId: varchar(12) [PK]
- BookingId: varchar(12) [FK tham chiếu đến Booking.BookingId]
- Rating: tinyint(3)
- Comment: varchar(1000) [N]
- CreatedAt: timestamp

16. Bảng `InventoryItem`
- ItemId: varchar(12) [PK]
- ItemName: varchar(100) [U]
- StockQuantity: integer(10)
- UnitCost: decimal(18, 2)
- UnitPrice: decimal(18, 2)
- LowStockThreshold: integer(10)
- isActive: bit

17. Bảng `InventoryAdjustment`
- AdjustmentId: varchar(12) [PK]
- ItemId: varchar(12) [FK tham chiếu đến InventoryItem.ItemId]
- EmployeeId: varchar(12) [FK tham chiếu đến EmployeeProfile.UserId]
- Quantity: integer(10)
- Type: varchar(20)
- Description: varchar(255) [N]
- CreatedAt: timestamp

18. Bảng `Expense`
- ExpenseId: varchar(12) [PK]
- AdjustmentId: varchar(12) [FK tham chiếu đến InventoryAdjustment.AdjustmentId]
- Amount: decimal(18, 2)
- Description: varchar(255)
- CreatedAt: timestamp

19. Bảng `Service`
- ServiceId: varchar(12) [PK]
- ServiceName: varchar(100) [U]
- Description: varchar(500) [N]
- Price: decimal(18, 2)
- isActive: bit

20. Bảng `Order`
- OrderId: varchar(12) [PK]
- EmployeeId: varchar(12) [FK tham chiếu đến EmployeeProfile.UserId]
- BookingId: varchar(12) [FK tham chiếu đến Booking.BookingId]
- TotalAmount: decimal(18, 2)
- Status: varchar(20)
- OrderedAt: timestamp

21. Bảng `ServiceOrder_InventoryItem` (Bảng trung gian)
- OrderId: varchar(12) [PK, FK tham chiếu đến Order.OrderId]
- ItemId: varchar(12) [PK, FK tham chiếu đến InventoryItem.ItemId]
- Quantity: integer(10)
- PriceAtOrder: decimal(18, 2)

22. Bảng `ServiceOrder_Service` (Bảng trung gian)
- ServiceId: varchar(12) [PK, FK tham chiếu đến Service.ServiceId]
- OrderId: varchar(12) [PK, FK tham chiếu đến Order.OrderId]
- Quantity: integer(10)
- PriceAtOrder: decimal(18, 2)

YÊU CẦU BỔ SUNG:
1. Đảm bảo đúng tất cả các kiểu dữ liệu và giới hạn độ dài (length).
2. Xử lý các trường hợp Not Null và Nullable chính xác như trên.
3. Liên kết các khóa ngoại (Foreign Keys) đầy đủ giữa các bảng.
