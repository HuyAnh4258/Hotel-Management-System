-- ============================================================
-- HOTEL MANAGEMENT SYSTEM (HMS) - Database Schema
-- Target: MySQL 8.0+
-- Encoding: utf8mb4 / Collation: utf8mb4_unicode_ci
-- Updated: 2026-07-14 (DATETIME, ID format, status enums)
--
-- ID FORMAT:
--   Static tables:     XXX-NNNNNNNN           (VARCHAR 12)
--   Transactional:     XXX-YYMMDDHHMMSS-HHHH  (VARCHAR 20)
--   Exception:         Room.RoomId = physical room number (VARCHAR 5)
-- ============================================================

CREATE DATABASE IF NOT EXISTS HotelDB_Schema
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE HotelDB_Schema;

-- ============================================================
-- 1. Roles (Static)
-- ============================================================
CREATE TABLE Roles (
    RoleId      VARCHAR(12)  NOT NULL COMMENT 'ROL-00000001',
    RoleName    VARCHAR(50)  NOT NULL,
    Description VARCHAR(255) NULL,
    CONSTRAINT pk_roles PRIMARY KEY (RoleId),
    CONSTRAINT uq_roles_name UNIQUE (RoleName)
) ENGINE=InnoDB;

-- ============================================================
-- 2. User (Static)
-- ============================================================
CREATE TABLE `User` (
    UserId         VARCHAR(12)  NOT NULL COMMENT 'USR-00000001',
    Username       VARCHAR(50)  NOT NULL,
    Email          VARCHAR(100) NOT NULL,
    HashedPassword VARCHAR(255) NOT NULL,
    IsActive       BIT          NOT NULL DEFAULT 1,
    CreatedAt      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user PRIMARY KEY (UserId),
    CONSTRAINT uq_user_username UNIQUE (Username),
    CONSTRAINT uq_user_email    UNIQUE (Email)
) ENGINE=InnoDB;

CREATE INDEX idx_user_username ON `User` (Username);
CREATE INDEX idx_user_email    ON `User` (Email);

-- ============================================================
-- 3. UserRole (Junction – no own ID)
-- ============================================================
CREATE TABLE UserRole (
    UserId VARCHAR(12) NOT NULL,
    RoleId VARCHAR(12) NOT NULL,
    CONSTRAINT pk_user_role PRIMARY KEY (UserId, RoleId),
    CONSTRAINT fk_ur_user FOREIGN KEY (UserId) REFERENCES `User` (UserId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (RoleId) REFERENCES Roles (RoleId)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 4. GuestProfile (Static)
-- ============================================================
CREATE TABLE GuestProfile (
    GuestId        VARCHAR(12)  NOT NULL COMMENT 'GST-00000001',
    UserId         VARCHAR(12)  NOT NULL,
    FullName       VARCHAR(100) NOT NULL,
    Phone          VARCHAR(10)  NOT NULL,
    IdentityNumber VARCHAR(20)  NULL,
    IdentityType   VARCHAR(20)  NULL COMMENT 'CCCD|CMND|PASSPORT',
    DateOfBirth    DATE         NULL,
    Gender         VARCHAR(10)  NULL COMMENT 'MALE|FEMALE|OTHER',
    Nationality    VARCHAR(50)  NULL,
    Address        VARCHAR(255) NULL,
    CONSTRAINT pk_guest_profile PRIMARY KEY (GuestId),
    CONSTRAINT uq_guest_phone    UNIQUE (Phone),
    CONSTRAINT uq_guest_identity UNIQUE (IdentityNumber),
    CONSTRAINT fk_guest_user FOREIGN KEY (UserId) REFERENCES `User` (UserId)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_guest_user ON GuestProfile (UserId);

-- ============================================================
-- 5. EmployeeProfile (Static)
-- ============================================================
CREATE TABLE EmployeeProfile (
    UserId     VARCHAR(12)   NOT NULL COMMENT 'EMP-00000001 (same as UserId)',
    EmployeeId VARCHAR(12)   NOT NULL COMMENT 'EMP-00000001',
    FullName   VARCHAR(100)  NOT NULL,
    Phone      VARCHAR(10)   NOT NULL,
    Salary     DECIMAL(18,2) NULL,
    HireDate   DATE          NOT NULL,
    CONSTRAINT pk_employee_profile PRIMARY KEY (UserId),
    CONSTRAINT uq_employee_id    UNIQUE (EmployeeId),
    CONSTRAINT uq_employee_phone UNIQUE (Phone),
    CONSTRAINT fk_employee_user FOREIGN KEY (UserId) REFERENCES `User` (UserId)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 6. AuditLog (Transactional)
-- ============================================================
CREATE TABLE AuditLog (
    LogId      VARCHAR(20)  NOT NULL COMMENT 'LOG-YYMMDDHHMMSS-HHHH',
    UserId     VARCHAR(12)  NOT NULL,
    ActionType VARCHAR(50)  NOT NULL COMMENT 'INSERT|UPDATE|DELETE',
    TableName  VARCHAR(100) NOT NULL,
    OldValues  TEXT         NULL,
    NewValues  TEXT         NULL,
    Timestamp  DATETIME     NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_audit_log PRIMARY KEY (LogId),
    CONSTRAINT fk_audit_user FOREIGN KEY (UserId) REFERENCES `User` (UserId)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_audit_user  ON AuditLog (UserId);
CREATE INDEX idx_audit_table ON AuditLog (TableName);
CREATE INDEX idx_audit_time  ON AuditLog (Timestamp);

-- ============================================================
-- 7. RoomType (Static)
-- ============================================================
CREATE TABLE RoomType (
    RoomTypeId   VARCHAR(12)   NOT NULL COMMENT 'RTP-00000001',
    TypeName     VARCHAR(50)   NOT NULL,
    Description  VARCHAR(255)  NULL,
    BasePrice    DECIMAL(18,2) NOT NULL,
    MaxOccupancy INT           NOT NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT pk_room_type PRIMARY KEY (RoomTypeId),
    CONSTRAINT uq_type_name  UNIQUE (TypeName)
) ENGINE=InnoDB;

-- ============================================================
-- 8. Room (Static – RoomId is physical room number)
-- ============================================================
CREATE TABLE Room (
    RoomId      VARCHAR(5)   NOT NULL COMMENT 'Physical room number, e.g. 101',
    RoomTypeId  VARCHAR(12)  NOT NULL,
    RoomName    VARCHAR(50)  NOT NULL,
    FloorNumber INT          NOT NULL,
    Status      VARCHAR(20)  NOT NULL DEFAULT 'AVAILABLE'
                             COMMENT 'AVAILABLE|OCCUPIED|DIRTY|CLEANING|MAINTENANCE',
    Description VARCHAR(255) NULL,
    IsActive    BIT          NOT NULL DEFAULT 1,
    CreatedAt   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   DATETIME     NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_room PRIMARY KEY (RoomId),
    CONSTRAINT uq_room_name UNIQUE (RoomName),
    CONSTRAINT fk_room_type FOREIGN KEY (RoomTypeId) REFERENCES RoomType (RoomTypeId)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_room_type   ON Room (RoomTypeId);
CREATE INDEX idx_room_status ON Room (Status);

-- ============================================================
-- 9. MaintenanceRequest (Transactional)
-- ============================================================
CREATE TABLE MaintenanceRequest (
    RequestId   VARCHAR(20)  NOT NULL COMMENT 'MNT-YYMMDDHHMMSS-HHHH',
    ReporterId  VARCHAR(12)  NOT NULL,
    RoomId      VARCHAR(5)   NOT NULL,
    Description VARCHAR(500) NOT NULL,
    Status      VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                             COMMENT 'PENDING|IN_PROGRESS|COMPLETED|CANCELLED',
    CreatedAt   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   DATETIME     NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_maintenance PRIMARY KEY (RequestId),
    CONSTRAINT fk_maint_reporter FOREIGN KEY (ReporterId)
        REFERENCES EmployeeProfile (UserId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_maint_room FOREIGN KEY (RoomId)
        REFERENCES Room (RoomId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_maint_reporter ON MaintenanceRequest (ReporterId);
CREATE INDEX idx_maint_room     ON MaintenanceRequest (RoomId);
CREATE INDEX idx_maint_status   ON MaintenanceRequest (Status);

-- ============================================================
-- 10. Voucher (Static)
-- ============================================================
CREATE TABLE Voucher (
    VoucherId         VARCHAR(12)   NOT NULL COMMENT 'VCH-00000001',
    VoucherCode       VARCHAR(50)   NOT NULL,
    DiscountPercent   DECIMAL(5,2)  NULL,
    MaxDiscountAmount DECIMAL(18,2) NULL,
    DiscountAmount    DECIMAL(18,2) NULL,
    MinBookingValue   DECIMAL(18,2) NULL,
    ExpiryTime        DATETIME      NOT NULL,
    IsActive          BIT           NOT NULL DEFAULT 1,
    CreatedAt         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_voucher PRIMARY KEY (VoucherId),
    CONSTRAINT uq_voucher_code UNIQUE (VoucherCode)
) ENGINE=InnoDB;

CREATE INDEX idx_voucher_code   ON Voucher (VoucherCode);
CREATE INDEX idx_voucher_expiry ON Voucher (ExpiryTime);

-- ============================================================
-- 11. Booking (Transactional)
-- ============================================================
CREATE TABLE Booking (
    BookingId        VARCHAR(20)   NOT NULL COMMENT 'BOK-YYMMDDHHMMSS-HHHH',
    GuestId          VARCHAR(12)   NOT NULL,
    VoucherId        VARCHAR(12)   NULL,
    ExpectedCheckin  DATETIME      NOT NULL,
    ExpectedCheckout DATETIME      NOT NULL,
    Status           VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                                   COMMENT 'PENDING|CONFIRMED|CHECKED_IN|CHECKED_OUT|CANCELLED|NO_SHOW',
    TotalAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    CreatedAt        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_booking PRIMARY KEY (BookingId),
    CONSTRAINT fk_booking_guest   FOREIGN KEY (GuestId)
        REFERENCES GuestProfile (GuestId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_booking_voucher FOREIGN KEY (VoucherId)
        REFERENCES Voucher (VoucherId) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_booking_guest   ON Booking (GuestId);
CREATE INDEX idx_booking_voucher ON Booking (VoucherId);
CREATE INDEX idx_booking_status  ON Booking (Status);
CREATE INDEX idx_booking_dates   ON Booking (ExpectedCheckin, ExpectedCheckout);

-- ============================================================
-- 12. RoomBooking (Transactional)
-- ============================================================
CREATE TABLE RoomBooking (
    RoomBookingId   VARCHAR(20)   NOT NULL COMMENT 'RMB-YYMMDDHHMMSS-HHHH',
    RoomId          VARCHAR(5)    NOT NULL,
    BookingId       VARCHAR(20)   NOT NULL,
    PriceAtBooking  DECIMAL(18,2) NOT NULL,
    ActualCheckin   DATETIME      NULL,
    ActualCheckout  DATETIME      NULL,
    Status          VARCHAR(20)   NOT NULL DEFAULT 'RESERVED'
                                  COMMENT 'RESERVED|CHECKED_IN|CHECKED_OUT|TRANSFERRED|CANCELLED',
    -- Self-reference: new RoomBookingId when guest transfers to another room
    TransferredTo   VARCHAR(20)   NULL,
    CONSTRAINT pk_room_booking PRIMARY KEY (RoomBookingId),
    CONSTRAINT fk_rb_room    FOREIGN KEY (RoomId)
        REFERENCES Room (RoomId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rb_booking FOREIGN KEY (BookingId)
        REFERENCES Booking (BookingId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_rb_room    ON RoomBooking (RoomId);
CREATE INDEX idx_rb_booking ON RoomBooking (BookingId);
CREATE INDEX idx_rb_status  ON RoomBooking (Status);

-- ============================================================
-- 13. Surcharge (Transactional)
-- ============================================================
CREATE TABLE Surcharge (
    SurchargeId   VARCHAR(20)   NOT NULL COMMENT 'SUR-YYMMDDHHMMSS-HHHH',
    RoomBookingId VARCHAR(20)   NOT NULL,
    Amount        DECIMAL(18,2) NOT NULL,
    Reason        VARCHAR(255)  NOT NULL,
    Type          VARCHAR(20)   NOT NULL COMMENT 'DAMAGE|LATE_CHECKOUT|EXTRA_SERVICE|OTHER',
    CreatedBy     VARCHAR(12)   NOT NULL,
    CreatedAt     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_surcharge PRIMARY KEY (SurchargeId),
    CONSTRAINT fk_surcharge_rb FOREIGN KEY (RoomBookingId)
        REFERENCES RoomBooking (RoomBookingId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_surcharge_creator FOREIGN KEY (CreatedBy)
        REFERENCES EmployeeProfile (UserId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_surcharge_rb ON Surcharge (RoomBookingId);

-- ============================================================
-- 14. Payment (Transactional)
-- ============================================================
CREATE TABLE Payment (
    PaymentId      VARCHAR(20)   NOT NULL COMMENT 'PAY-YYMMDDHHMMSS-HHHH',
    BookingId      VARCHAR(20)   NOT NULL,
    Amount         DECIMAL(18,2) NOT NULL,
    PaymentType    VARCHAR(20)   NOT NULL DEFAULT 'FULL'
                                 COMMENT 'DEPOSIT|FULL|PARTIAL|REFUND',
    PaymentMethod  VARCHAR(50)   NOT NULL COMMENT 'CASH|CARD|VNPAY|BANK_TRANSFER',
    PaidAt         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status         VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                                 COMMENT 'PENDING|PARTIALLY_PAID|COMPLETED|FAILED|REFUNDED',
    TransactionRef VARCHAR(255)  NULL,
    CONSTRAINT pk_payment PRIMARY KEY (PaymentId),
    CONSTRAINT fk_payment_booking FOREIGN KEY (BookingId)
        REFERENCES Booking (BookingId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_payment_booking ON Payment (BookingId);
CREATE INDEX idx_payment_status  ON Payment (Status);

-- ============================================================
-- 15. Feedback (Transactional)
-- ============================================================
CREATE TABLE Feedback (
    FeedbackId VARCHAR(20)   NOT NULL COMMENT 'FDB-YYMMDDHHMMSS-HHHH',
    BookingId  VARCHAR(20)   NOT NULL,
    Rating     TINYINT       NOT NULL,
    Comment    VARCHAR(1000) NULL,
    CreatedAt  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_feedback PRIMARY KEY (FeedbackId),
    CONSTRAINT fk_feedback_booking FOREIGN KEY (BookingId)
        REFERENCES Booking (BookingId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_feedback_booking UNIQUE (BookingId),
    CONSTRAINT chk_feedback_rating CHECK (Rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- ============================================================
-- 16. InventoryItem (Static)
-- ============================================================
CREATE TABLE InventoryItem (
    ItemId            VARCHAR(12)   NOT NULL COMMENT 'INV-00000001',
    ItemName          VARCHAR(100)  NOT NULL,
    StockQuantity     INT           NOT NULL DEFAULT 0,
    UnitCost          DECIMAL(18,2) NOT NULL,
    UnitPrice         DECIMAL(18,2) NOT NULL,
    LowStockThreshold INT           NOT NULL DEFAULT 5,
    IsActive          BIT           NOT NULL DEFAULT 1,
    CreatedAt         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt         DATETIME      NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_inventory_item PRIMARY KEY (ItemId),
    CONSTRAINT uq_item_name UNIQUE (ItemName)
) ENGINE=InnoDB;

-- ============================================================
-- 17. InventoryAdjustment (Transactional)
-- ============================================================
CREATE TABLE InventoryAdjustment (
    AdjustmentId VARCHAR(20)  NOT NULL COMMENT 'ADJ-YYMMDDHHMMSS-HHHH',
    ItemId       VARCHAR(12)  NOT NULL,
    EmployeeId   VARCHAR(12)  NOT NULL,
    Quantity     INT          NOT NULL,
    Type         VARCHAR(20)  NOT NULL COMMENT 'IMPORT|EXPORT',
    Description  VARCHAR(255) NULL,
    CreatedAt    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_inventory_adj PRIMARY KEY (AdjustmentId),
    CONSTRAINT fk_adj_item     FOREIGN KEY (ItemId)
        REFERENCES InventoryItem (ItemId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_adj_employee FOREIGN KEY (EmployeeId)
        REFERENCES EmployeeProfile (UserId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_adj_item     ON InventoryAdjustment (ItemId);
CREATE INDEX idx_adj_employee ON InventoryAdjustment (EmployeeId);

-- ============================================================
-- 18. Expense (Transactional)
-- ============================================================
CREATE TABLE Expense (
    ExpenseId    VARCHAR(20)   NOT NULL COMMENT 'EXP-YYMMDDHHMMSS-HHHH',
    AdjustmentId VARCHAR(20)   NOT NULL,
    Amount       DECIMAL(18,2) NOT NULL,
    Description  VARCHAR(255)  NOT NULL,
    CreatedAt    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_expense PRIMARY KEY (ExpenseId),
    CONSTRAINT fk_expense_adj FOREIGN KEY (AdjustmentId)
        REFERENCES InventoryAdjustment (AdjustmentId)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 19. Service (Static)
-- ============================================================
CREATE TABLE Service (
    ServiceId   VARCHAR(12)   NOT NULL COMMENT 'SRV-00000001',
    ServiceName VARCHAR(100)  NOT NULL,
    Description VARCHAR(500)  NULL,
    Price       DECIMAL(18,2) NOT NULL,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   DATETIME      NULL     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_service PRIMARY KEY (ServiceId),
    CONSTRAINT uq_service_name UNIQUE (ServiceName)
) ENGINE=InnoDB;

-- ============================================================
-- 20. Order (Transactional – backtick: ORDER is SQL keyword)
-- ============================================================
CREATE TABLE `Order` (
    OrderId     VARCHAR(20)   NOT NULL COMMENT 'ORD-YYMMDDHHMMSS-HHHH',
    EmployeeId  VARCHAR(12)   NOT NULL,
    BookingId   VARCHAR(20)   NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    Status      VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                              COMMENT 'PENDING|IN_PROGRESS|COMPLETED|CANCELLED',
    OrderedAt   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_order PRIMARY KEY (OrderId),
    CONSTRAINT fk_order_employee FOREIGN KEY (EmployeeId)
        REFERENCES EmployeeProfile (UserId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_booking  FOREIGN KEY (BookingId)
        REFERENCES Booking (BookingId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_order_booking  ON `Order` (BookingId);
CREATE INDEX idx_order_employee ON `Order` (EmployeeId);

-- ============================================================
-- 21. ServiceOrder_InventoryItem (Order N-N InventoryItem)
-- ============================================================
CREATE TABLE ServiceOrder_InventoryItem (
    OrderId      VARCHAR(20)   NOT NULL,
    ItemId       VARCHAR(12)   NOT NULL,
    Quantity     INT           NOT NULL DEFAULT 1,
    PriceAtOrder DECIMAL(18,2) NOT NULL,
    CONSTRAINT pk_order_item PRIMARY KEY (OrderId, ItemId),
    CONSTRAINT fk_oi_order FOREIGN KEY (OrderId)
        REFERENCES `Order` (OrderId) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_oi_item  FOREIGN KEY (ItemId)
        REFERENCES InventoryItem (ItemId) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 22. ServiceOrder_Service (Order N-N Service)
-- ============================================================
CREATE TABLE ServiceOrder_Service (
    ServiceId    VARCHAR(12)   NOT NULL,
    OrderId      VARCHAR(20)   NOT NULL,
    Quantity     INT           NOT NULL DEFAULT 1,
    PriceAtOrder DECIMAL(18,2) NOT NULL,
    CONSTRAINT pk_order_service PRIMARY KEY (ServiceId, OrderId),
    CONSTRAINT fk_os_service FOREIGN KEY (ServiceId)
        REFERENCES Service (ServiceId) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_os_order   FOREIGN KEY (OrderId)
        REFERENCES `Order` (OrderId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO Roles (RoleId, RoleName, Description) VALUES
('ROL-00000001', 'OWNER',          'Chủ khách sạn'),
('ROL-00000002', 'MANAGER',        'Quản lý khách sạn'),
('ROL-00000003', 'RECEPTIONIST',   'Lễ tân'),
('ROL-00000004', 'SERVICE_STAFF',  'Nhân viên phục vụ'),
('ROL-00000005', 'HOUSEKEEPER',    'Nhân viên buồng phòng'),
('ROL-00000006', 'GUEST',          'Khách sử dụng dịch vụ');

INSERT INTO RoomType (RoomTypeId, TypeName, Description, BasePrice, MaxOccupancy) VALUES
('RTP-00000001', 'Standard', 'Phòng tiêu chuẩn',           500000,  2),
('RTP-00000002', 'Deluxe',   'Phòng cao cấp có view',      800000,  2),
('RTP-00000003', 'Superior', 'Phòng Superior rộng rãi',    650000,  3),
('RTP-00000004', 'Suite',    'Phòng Suite sang trọng',    1500000, 4);
