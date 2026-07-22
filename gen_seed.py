import datetime

sql = []

# Create a booking
booking_id = 'BOK-260722000000-9999'
sql.append(f"INSERT INTO Booking (BookingId, GuestId, ExpectedCheckin, ExpectedCheckout, Status) VALUES ('{booking_id}', 'GST-00000001', '2026-07-22 14:00:00', '2026-07-25 12:00:00', 'CHECKED_IN');")
sql.append(f"INSERT INTO RoomBooking (BookingId, RoomId, PriceAtBooking) VALUES ('{booking_id}', '101', 500000);")

# 20 Orders for Service Staff (EMP-00000004)
for i in range(1, 21):
    order_id = f'ORD-2607220000{i:02d}-0001'
    sql.append(f"INSERT INTO \`Order\` (OrderId, EmployeeId, BookingId, TotalAmount, Status) VALUES ('{order_id}', 'EMP-00000004', '{booking_id}', 100000, 'PENDING');")
    # Using ServiceId SRV-00000001
    sql.append(f"INSERT INTO ServiceOrder_Service (OrderId, ServiceId, Quantity, PriceAtOrder) VALUES ('{order_id}', 'SRV-00000001', 1, 100000);")

# 20 Housekeeping requests for Housekeeper (let's use EMP-00000005 as reporter)
for i in range(1, 21):
    req_id = f'MNT-2607220000{i:02d}-0002'
    sql.append(f"INSERT INTO MaintenanceRequest (RequestId, ReporterId, RoomId, Description, Status) VALUES ('{req_id}', 'EMP-00000005', '101', 'Yêu cầu dọn phòng khách {i}', 'PENDING');")

with open('seed_data.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql) + '\n')
