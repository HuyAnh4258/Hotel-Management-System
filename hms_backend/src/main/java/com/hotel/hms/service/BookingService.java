package com.hotel.hms.service;

import com.hotel.hms.dto.BookingSummary;
import com.hotel.hms.dto.CreateBookingRequest;
import com.hotel.hms.dto.HomepageResponse;
import com.hotel.hms.dto.RoomSummary;
import com.hotel.hms.dto.RoomTypeSummary;
import com.hotel.hms.entity.Booking;
import com.hotel.hms.entity.GuestProfile;
import com.hotel.hms.entity.Room;
import com.hotel.hms.entity.RoomBooking;
import com.hotel.hms.entity.RoomType;
import com.hotel.hms.entity.Voucher;
import com.hotel.hms.repository.BookingRepository;
import com.hotel.hms.repository.GuestProfileRepository;
import com.hotel.hms.repository.RoomBookingRepository;
import com.hotel.hms.repository.RoomRepository;
import com.hotel.hms.repository.RoomTypeRepository;
import com.hotel.hms.repository.VoucherRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class BookingService {
    private final RoomTypeRepository roomTypeRepository;
    private final RoomRepository roomRepository;
    private final BookingRepository bookingRepository;
    private final RoomBookingRepository roomBookingRepository;
    private final GuestProfileRepository guestProfileRepository;
    private final VoucherRepository voucherRepository;

    @PersistenceContext
    private EntityManager entityManager;

    public BookingService(
            RoomTypeRepository roomTypeRepository,
            RoomRepository roomRepository,
            BookingRepository bookingRepository,
            RoomBookingRepository roomBookingRepository,
            GuestProfileRepository guestProfileRepository,
            VoucherRepository voucherRepository
    ) {
        this.roomTypeRepository = roomTypeRepository;
        this.roomRepository = roomRepository;
        this.bookingRepository = bookingRepository;
        this.roomBookingRepository = roomBookingRepository;
        this.guestProfileRepository = guestProfileRepository;
        this.voucherRepository = voucherRepository;
    }

    @Transactional(readOnly = true)
    public HomepageResponse getHomepage() {
        List<RoomTypeSummary> roomTypes = roomTypeRepository.findAll().stream()
                .filter(roomType -> roomType.getIsActive() == null || roomType.getIsActive())
                .map(this::toRoomTypeSummary)
                .toList();

        List<RoomSummary> availableRooms = roomRepository.findByIsActiveTrue().stream()
                .filter(room -> room.getStatus() == null || "AVAILABLE".equalsIgnoreCase(room.getStatus()))
                .map(this::toRoomSummary)
                .toList();

        List<BookingSummary> recentBookings = bookingRepository.findTop8ByOrderByCreatedAtDesc().stream()
                .map(this::toBookingSummary)
                .toList();

        return new HomepageResponse(roomTypes, availableRooms, recentBookings);
    }

    @Transactional(readOnly = true)
    public List<BookingSummary> getBookingsByDate(LocalDate date) {
        return bookingRepository.findAll().stream()
                .map(this::toBookingSummary)
                .filter(booking ->
                        (booking.expectedCheckin() != null && booking.expectedCheckin().startsWith(date.toString()))
                                || (booking.expectedCheckout() != null && booking.expectedCheckout().startsWith(date.toString())))
                .toList();
    }

    @Transactional
    public BookingSummary updateBookingStatus(String bookingId, String status) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        setField(booking, "status", status);
        booking = bookingRepository.save(booking);
        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary createBooking(CreateBookingRequest request) {
        String guestName = request.guestName() == null ? "" : request.guestName().trim();
        String phone = request.phone() == null ? "" : request.phone().trim();

        if (guestName.isEmpty()) throw new IllegalArgumentException("guestName is required");
        if (phone.isEmpty()) throw new IllegalArgumentException("phone is required");
        if (request.expectedCheckin() == null || request.expectedCheckout() == null) {
            throw new IllegalArgumentException("expectedCheckin and expectedCheckout are required");
        }
        if (request.expectedCheckout().isBefore(request.expectedCheckin())) {
            throw new IllegalArgumentException("expectedCheckout must be after expectedCheckin");
        }
        if (request.roomIds() == null || request.roomIds().isEmpty()) {
            throw new IllegalArgumentException("roomIds is required");
        }

        GuestProfile guest = guestProfileRepository.findByPhone(phone)
                .orElseGet(() -> createGuestProfile(guestName, phone, request.email()));

        Voucher voucher = resolveVoucher(request.voucherCode());

        Booking booking = new Booking();
        setField(booking, "bookingId", generateId("BOK", 20));
        setField(booking, "guest", guest);
        setField(booking, "voucher", voucher);
        setField(booking, "expectedCheckin", request.expectedCheckin().atStartOfDay());
        setField(booking, "expectedCheckout", request.expectedCheckout().atStartOfDay());
        setField(booking, "status", "PENDING");
        setField(booking, "createdAt", LocalDateTime.now());

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<RoomBooking> roomBookings = new ArrayList<>();

        for (String roomId : request.roomIds()) {
            Room room = roomRepository.findById(roomId)
                    .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));

            BigDecimal roomPrice = room.getRoomType() != null && room.getRoomType().getBasePrice() != null
                    ? room.getRoomType().getBasePrice()
                    : BigDecimal.ZERO;
            totalAmount = totalAmount.add(roomPrice);

            RoomBooking roomBooking = new RoomBooking();
            setField(roomBooking, "roomBookingId", generateId("RMB", 20));
            setField(roomBooking, "room", room);
            setField(roomBooking, "booking", booking);
            setField(roomBooking, "priceAtBooking", roomPrice);
            setField(roomBooking, "status", "RESERVED");
            roomBookings.add(roomBooking);
        }

        setField(booking, "totalAmount", totalAmount);

        bookingRepository.saveAndFlush(booking);
        roomBookingRepository.saveAllAndFlush(roomBookings);

        return toBookingSummary(booking);
    }

    private GuestProfile createGuestProfile(String fullName, String phone, String email) {
        String userId = createUserAccount(fullName, email, phone);

        GuestProfile guest = new GuestProfile();
        setField(guest, "guestId", generateId("GST", 12));
        setField(guest, "userId", userId);
        setField(guest, "fullName", fullName);
        setField(guest, "phone", phone);
        return guestProfileRepository.save(guest);
    }

    private String createUserAccount(String fullName, String email, String phone) {
        String userId = generateId("USR", 12);
        String username = (email != null && !email.trim().isEmpty())
                ? email.trim()
                : phone + "_" + userId;
        String normalizedEmail = (email != null && !email.trim().isEmpty())
                ? email.trim()
                : username + "@guest.local";

        entityManager.createNativeQuery("""
                INSERT INTO `User` (UserId, Username, Email, HashedPassword, IsActive, CreatedAt)
                VALUES (:userId, :username, :email, :hashedPassword, 1, NOW())
                """)
                .setParameter("userId", userId)
                .setParameter("username", username)
                .setParameter("email", normalizedEmail)
                .setParameter("hashedPassword", "BOOKING-GUEST")
                .executeUpdate();

        return userId;
    }

    private Voucher resolveVoucher(String voucherCode) {
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            return null;
        }
        return voucherRepository.findByVoucherCodeIgnoreCase(voucherCode.trim()).orElse(null);
    }

    private String generateId(String prefix, int maxLength) {
        StringBuilder value = new StringBuilder(prefix);
        String digits = String.valueOf(System.currentTimeMillis());

        for (int i = digits.length() - 1; i >= 0 && value.length() < maxLength; i--) {
            value.append(digits.charAt(i));
        }

        while (value.length() < maxLength) {
            value.append((char) ('0' + Math.abs((int) System.nanoTime()) % 10));
        }

        return value.substring(0, maxLength);
    }

    private void setField(Object target, String fieldName, Object value) {
        try {
            Field field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(target, value);
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException(
                    "Unable to set field " + fieldName + " on " + target.getClass().getSimpleName(), e);
        }
    }

    private RoomTypeSummary toRoomTypeSummary(RoomType roomType) {
        return new RoomTypeSummary(
                roomType.getRoomTypeId(),
                roomType.getTypeName(),
                roomType.getDescription(),
                roomType.getBasePrice(),
                roomType.getMaxOccupancy()
        );
    }

    private RoomSummary toRoomSummary(Room room) {
        return new RoomSummary(
                room.getRoomId(),
                room.getRoomName(),
                room.getFloorNumber(),
                room.getStatus(),
                room.getDescription(),
                toRoomTypeSummary(room.getRoomType())
        );
    }

    private BookingSummary toBookingSummary(Booking booking) {
        List<String> roomIds = roomBookingRepository.findByBookingId(booking.getBookingId()).stream()
                .map(roomBooking -> roomBooking.getRoom().getRoomId())
                .toList();

        return new BookingSummary(
                booking.getBookingId(),
                booking.getGuest() != null ? booking.getGuest().getFullName() : "",
                booking.getGuest() != null ? booking.getGuest().getPhone() : "",
                booking.getExpectedCheckin() != null ? booking.getExpectedCheckin().toString() : "",
                booking.getExpectedCheckout() != null ? booking.getExpectedCheckout().toString() : "",
                booking.getStatus(),
                booking.getTotalAmount(),
                roomIds
        );
    }
}