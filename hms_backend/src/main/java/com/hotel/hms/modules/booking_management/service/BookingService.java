package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.BookingSummary;
import com.hotel.hms.modules.booking_management.dto.CreateBookingRequest;
import com.hotel.hms.modules.booking_management.dto.HomepageResponse;
import com.hotel.hms.modules.booking_management.dto.RoomSummary;
import com.hotel.hms.modules.booking_management.dto.RoomTypeSummary;
import com.hotel.hms.modules.booking_management.entity.Booking;
import com.hotel.hms.modules.authentication.entity.GuestProfile;
import com.hotel.hms.modules.authentication.entity.User;
import com.hotel.hms.modules.booking_management.entity.Room;
import com.hotel.hms.modules.booking_management.entity.RoomBooking;
import com.hotel.hms.modules.booking_management.entity.RoomType;
import com.hotel.hms.modules.booking_management.entity.Voucher;
import com.hotel.hms.modules.booking_management.repository.BookingRepository;
import com.hotel.hms.modules.authentication.repository.GuestProfileRepository;
import com.hotel.hms.modules.authentication.repository.UserRepository;
import com.hotel.hms.modules.booking_management.repository.RoomBookingRepository;
import com.hotel.hms.modules.booking_management.repository.RoomRepository;
import com.hotel.hms.modules.booking_management.repository.RoomTypeRepository;
import com.hotel.hms.modules.booking_management.repository.VoucherRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
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
    private final UserRepository userRepository;

    @PersistenceContext
    private EntityManager entityManager;

    public BookingService(
            RoomTypeRepository roomTypeRepository,
            RoomRepository roomRepository,
            BookingRepository bookingRepository,
            RoomBookingRepository roomBookingRepository,
            GuestProfileRepository guestProfileRepository,
            VoucherRepository voucherRepository,
            UserRepository userRepository
    ) {
        this.roomTypeRepository = roomTypeRepository;
        this.roomRepository = roomRepository;
        this.bookingRepository = bookingRepository;
        this.roomBookingRepository = roomBookingRepository;
        this.guestProfileRepository = guestProfileRepository;
        this.voucherRepository = voucherRepository;
        this.userRepository = userRepository;
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
    public List<BookingSummary> getAllBookings() {
        return bookingRepository.findAll().stream()
                .map(this::toBookingSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<BookingSummary> getBookingsForGuest(String userId) {
        if (userId == null || userId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "userId is required");
        }

        return bookingRepository.findByGuest_User_UserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toBookingSummary)
                .toList();
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

    @Transactional(readOnly = true)
    public List<RoomSummary> getRoomsByStatus(String status) {
        return roomRepository.findByIsActiveTrue().stream()
                .filter(room -> status == null
                        || status.isBlank()
                        || "ALL".equalsIgnoreCase(status)
                        || (room.getStatus() != null && room.getStatus().equalsIgnoreCase(status)))
                .map(this::toRoomSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RoomSummary> getAvailableRoomsByDateRange(LocalDate checkin, LocalDate checkout) {
        if (checkin == null || checkout == null) {
            throw new IllegalArgumentException("checkin and checkout are required");
        }
        if (checkout.isBefore(checkin) || checkout.isEqual(checkin)) {
            throw new IllegalArgumentException("checkout must be after checkin");
        }

        LocalDateTime checkinDateTime = toNoon(checkin);
        LocalDateTime checkoutDateTime = toNoon(checkout);

        return roomRepository.findByIsActiveTrue().stream()
                .filter(room -> room.getStatus() == null || "AVAILABLE".equalsIgnoreCase(room.getStatus()))
                .filter(room -> room.getRoomId() != null)
                .filter(room -> roomBookingRepository.findOverlappingBookings(
                        room.getRoomId(),
                        checkinDateTime,
                        checkoutDateTime
                ).isEmpty())
                .map(this::toRoomSummary)
                .toList();
    }

    @Transactional
    public BookingSummary updateBookingStatus(String bookingId, String status) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));
        setField(booking, "totalAmount", calculateBookingTotal(bookingId));
        setField(booking, "status", status);
        booking = bookingRepository.save(booking);

        if ("CHECKED_OUT".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) {
            releaseRoomsForBooking(bookingId);
        }

        return toBookingSummary(booking);
    }

    @Transactional(readOnly = true)
    public List<RoomSummary> getChangeableRooms(String bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        List<RoomBooking> roomBookings = roomBookingRepository.findByBookingId(bookingId);
        if (roomBookings.isEmpty()) {
            return List.of();
        }

        Room currentRoom = roomBookings.get(0).getRoom();
        if (currentRoom == null || currentRoom.getRoomType() == null) {
            return List.of();
        }

        LocalDateTime checkin = booking.getExpectedCheckin();
        LocalDateTime checkout = booking.getExpectedCheckout();
        String roomTypeId = currentRoom.getRoomType().getRoomTypeId();

        List<RoomSummary> changeableRooms = roomRepository.findByIsActiveTrue().stream()
                .filter(room -> room.getRoomId() != null)
                .filter(room -> room.getRoomType() != null
                        && roomTypeId.equals(room.getRoomType().getRoomTypeId()))
                .filter(room -> room.getRoomId().equals(currentRoom.getRoomId())
                        || ("AVAILABLE".equalsIgnoreCase(room.getStatus())
                        && roomBookingRepository.findOverlappingBookings(
                        room.getRoomId(),
                        checkin,
                        checkout
                ).isEmpty()))
                .map(this::toRoomSummary)
                .toList();

        List<RoomSummary> result = new ArrayList<>();
        result.add(toRoomSummary(currentRoom));
        for (RoomSummary roomSummary : changeableRooms) {
            if (!roomSummary.roomId().equals(currentRoom.getRoomId())) {
                result.add(roomSummary);
            }
        }
        return result;
    }

    @Transactional
    public BookingSummary changeBookingRoom(String bookingId, String newRoomId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        List<RoomBooking> roomBookings = roomBookingRepository.findByBookingId(bookingId);
        if (roomBookings.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Booking has no room to change");
        }

        RoomBooking currentRoomBooking = roomBookings.get(0);
        Room currentRoom = currentRoomBooking.getRoom();
        if (currentRoom == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Current room not found");
        }

        Room newRoom = roomRepository.findById(newRoomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "New room not found"));

        if (newRoom.getRoomType() == null || currentRoom.getRoomType() == null
                || !newRoom.getRoomType().getRoomTypeId().equals(currentRoom.getRoomType().getRoomTypeId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New room must be in the same room type");
        }

        if (newRoom.getStatus() != null
                && !"AVAILABLE".equalsIgnoreCase(newRoom.getStatus())
                && !newRoom.getRoomId().equals(currentRoom.getRoomId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Selected room is not available");
        }

        LocalDateTime checkin = booking.getExpectedCheckin();
        LocalDateTime checkout = booking.getExpectedCheckout();
        if (newRoom.getRoomId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New room id is required");
        }
        boolean hasOverlap = !roomBookingRepository.findOverlappingBookings(newRoom.getRoomId(), checkin, checkout).isEmpty();
        if (hasOverlap) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Selected room is already booked");
        }

        setField(currentRoom, "status", "AVAILABLE");
        roomRepository.save(currentRoom);

        setField(currentRoomBooking, "room", newRoom);
        setField(newRoom, "status", "BOOKED");
        roomRepository.save(newRoom);
        roomBookingRepository.save(currentRoomBooking);

        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary requestCancelBooking(String bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        if (isPastCancellationDeadline(booking)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Đã quá hạn đặt phòng"
            );
        }

        setField(booking, "status", "WAITING_APPROVAL");
        booking = bookingRepository.save(booking);
        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary approveCancelBooking(String bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        setField(booking, "status", "CANCELLED");
        booking = bookingRepository.save(booking);

        releaseRoomsForBooking(bookingId);

        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary rejectCancelBooking(String bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        setField(booking, "status", "CANCEL_REJECTED");
        booking = bookingRepository.save(booking);
        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary updateBookingDetails(String bookingId, CreateBookingRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Booking not found"));

        String guestName = request.guestName() == null ? "" : request.guestName().trim();
        String phone = request.phone() == null ? "" : request.phone().trim();

        if (guestName.isEmpty()) throw new IllegalArgumentException("guestName is required");
        if (phone.isEmpty()) throw new IllegalArgumentException("phone is required");

        GuestProfile guest = booking.getGuest();
        if (guest == null) {
            guest = guestProfileRepository.findByPhone(phone)
                    .orElseGet(() -> createGuestProfile(guestName, phone, request.email()));
            setField(booking, "guest", guest);
        } else {
            setField(guest, "fullName", guestName);
            setField(guest, "phone", phone);
            guest = guestProfileRepository.save(guest);
            setField(booking, "guest", guest);
        }

        if (request.email() != null && !request.email().trim().isEmpty()) {
            updateGuestEmail(guest.getUser().getUserId(), request.email().trim());
        }

        if (request.roomIds() != null && !request.roomIds().isEmpty()) {
            String newRoomId = request.roomIds().get(0);
            List<RoomBooking> currentRoomBookings = roomBookingRepository.findByBookingId(bookingId);
            if (!currentRoomBookings.isEmpty()) {
                RoomBooking currentRoomBooking = currentRoomBookings.get(0);
                Room currentRoom = currentRoomBooking.getRoom();

                if (currentRoom != null && currentRoom.getRoomId() != null && !currentRoom.getRoomId().equals(newRoomId)) {
                    Room newRoom = roomRepository.findById(newRoomId)
                            .orElseThrow(() -> new IllegalArgumentException("Room not found: " + newRoomId));

                    if (newRoom.getRoomType() == null || currentRoom.getRoomType() == null
                            || !newRoom.getRoomType().getRoomTypeId().equals(currentRoom.getRoomType().getRoomTypeId())) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New room must be in the same room type");
                    }

                    if (newRoom.getStatus() != null
                            && !"AVAILABLE".equalsIgnoreCase(newRoom.getStatus())
                            && !newRoom.getRoomId().equals(currentRoom.getRoomId())) {
                        throw new ResponseStatusException(HttpStatus.CONFLICT, "Selected room is not available");
                    }

                    ensureRoomIsAvailable(newRoomId,
                            booking.getExpectedCheckin(),
                            booking.getExpectedCheckout());

                    setField(currentRoom, "status", "AVAILABLE");
                    roomRepository.save(currentRoom);

                    setField(newRoom, "status", "BOOKED");
                    roomRepository.save(newRoom);

                    setField(currentRoomBooking, "room", newRoom);
                    setField(currentRoomBooking, "status", "RESERVED");
                    roomBookingRepository.save(currentRoomBooking);
                }
            }
        }

        booking = bookingRepository.save(booking);
        return toBookingSummary(booking);
    }

    @Transactional
    public BookingSummary createBooking(CreateBookingRequest request) {
        String guestName = request.guestName() == null ? "" : request.guestName().trim();
        String phone = request.phone() == null ? "" : request.phone().trim();

        if (guestName.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "guestName is required");
        }
        if (phone.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "phone is required");
        }
        if (request.expectedCheckin() == null || request.expectedCheckout() == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "expectedCheckin and expectedCheckout are required"
            );
        }
        if (request.expectedCheckout().isBefore(request.expectedCheckin())
                || request.expectedCheckout().isEqual(request.expectedCheckin())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "expectedCheckout must be after expectedCheckin"
            );
        }
        if (request.roomIds() == null || request.roomIds().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "roomIds is required");
        }

        GuestProfile guest = null;
        if (request.userId() != null && !request.userId().isBlank()) {
            guest = guestProfileRepository.findByUser_UserId(request.userId().trim()).orElse(null);
        }
        if (guest == null && phone != null && !phone.isBlank()) {
            guest = guestProfileRepository.findByPhone(phone)
                    .orElse(null);
        }
        if (guest == null) {
            guest = createGuestProfile(guestName, phone, request.email());
        } else {
            setField(guest, "fullName", guestName);
            setField(guest, "phone", phone);
            guest = guestProfileRepository.save(guest);
            if (request.email() != null && !request.email().trim().isEmpty()) {
                updateGuestEmail(guest.getUser().getUserId(), request.email().trim());
            }
        }

        Voucher voucher = resolveVoucher(request.voucherCode());

        LocalDateTime checkinDateTime = toNoon(request.expectedCheckin());
        LocalDateTime checkoutDateTime = toNoon(request.expectedCheckout());
        long nights = ChronoUnit.DAYS.between(request.expectedCheckin(), request.expectedCheckout());
        if (nights <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Booking nights must be greater than zero"
            );
        }

        Booking booking = new Booking();
        setField(booking, "bookingId", generateId("BOK", 20));
        setField(booking, "guest", guest);
        setField(booking, "voucher", voucher);
        setField(booking, "expectedCheckin", checkinDateTime);
        setField(booking, "expectedCheckout", checkoutDateTime);
        setField(booking, "status", "PENDING");
        setField(booking, "createdAt", LocalDateTime.now());

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<RoomBooking> roomBookings = new ArrayList<>();

        for (String roomId : request.roomIds()) {
            Room room = roomRepository.findById(roomId)
                    .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));

            ensureRoomIsAvailable(roomId, checkinDateTime, checkoutDateTime);

            BigDecimal roomPricePerNight = room.getRoomType() != null && room.getRoomType().getBasePrice() != null
                    ? room.getRoomType().getBasePrice()
                    : BigDecimal.ZERO;
            BigDecimal roomTotalPrice = roomPricePerNight.multiply(BigDecimal.valueOf(nights));
            totalAmount = totalAmount.add(roomTotalPrice);

            RoomBooking roomBooking = new RoomBooking();
            setField(roomBooking, "roomBookingId", generateId("RMB", 20));
            setField(roomBooking, "room", room);
            setField(roomBooking, "booking", booking);
            setField(roomBooking, "priceAtBooking", roomTotalPrice);
            setField(roomBooking, "status", "RESERVED");
            roomBookings.add(roomBooking);

            setField(room, "status", "BOOKED");
            roomRepository.save(room);
        }

        setField(booking, "totalAmount", totalAmount);

        bookingRepository.saveAndFlush(booking);
        roomBookingRepository.saveAllAndFlush(roomBookings);

        return toBookingSummary(booking);
    }

    private GuestProfile createGuestProfile(String fullName, String phone, String email) {
        User user = createUserAccount(fullName, email, phone);

        GuestProfile guest = new GuestProfile();
        setField(guest, "guestId", generateId("GST", 12));
        setField(guest, "user", user);
        setField(guest, "fullName", fullName);
        setField(guest, "phone", phone);
        return guestProfileRepository.save(guest);
    }

    private User createUserAccount(String fullName, String email, String phone) {
        String userId = generateId("USR", 12);
        String username = (email != null && !email.trim().isEmpty())
                ? email.trim()
                : phone + "_" + userId;
        String normalizedEmail = (email != null && !email.trim().isEmpty())
                ? email.trim()
                : username + "@guest.local";

        try {
            User user = User.builder()
                    .userId(userId)
                    .username(username)
                    .email(normalizedEmail)
                    .hashedPassword("BOOKING-GUEST")
                    .isActive(true)
                    .build();
            return userRepository.save(user);
        } catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Could not create guest account for booking",
                    e
            );
        }
    }

    private void updateGuestEmail(String userId, String email) {
        if (userId == null || userId.isBlank() || email == null || email.isBlank()) {
            return;
        }

        userRepository.findById(userId).ifPresent(user -> {
            user.setEmail(email);
            user.setUsername(email);
            userRepository.save(user);
        });
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

    private LocalDateTime toNoon(LocalDate date) {
        return date.atTime(LocalTime.NOON);
    }

    private boolean isPastCancellationDeadline(Booking booking) {
        LocalDateTime checkinDeadline = booking.getExpectedCheckin();
        return checkinDeadline != null && !LocalDateTime.now().isBefore(checkinDeadline);
    }

    private void releaseRoomsForBooking(String bookingId) {
        List<RoomBooking> roomBookings = roomBookingRepository.findByBookingId(bookingId);

        for (RoomBooking roomBooking : roomBookings) {
            Room room = roomBooking.getRoom();
            if (room == null || room.getRoomId() == null) {
                continue;
            }

            setField(room, "status", "AVAILABLE");
            roomRepository.saveAndFlush(room);

            setField(roomBooking, "status", "RELEASED");
            roomBookingRepository.save(roomBooking);
        }

        roomBookingRepository.flush();
        roomRepository.flush();
    }

    private void ensureRoomIsAvailable(String roomId, LocalDateTime checkin, LocalDateTime checkout) {
        boolean hasOverlap = !roomBookingRepository.findOverlappingBookings(roomId, checkin, checkout).isEmpty();
        if (hasOverlap) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Room is already booked in the selected date range: " + roomId
            );
        }
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

    private String getGuestEmail(Booking booking) {
        if (booking.getGuest() == null || booking.getGuest().getUser() == null
                || booking.getGuest().getUser().getUserId() == null) {
            return "";
        }

        try {
            User user = booking.getGuest().getUser();
            return user.getEmail() != null ? user.getEmail() : "";
        } catch (Exception e) {
            return "";
        }
    }

    private RoomTypeSummary toRoomTypeSummary(RoomType roomType) {
        return new RoomTypeSummary(
                roomType.getRoomTypeId(),
                roomType.getTypeName(),
                roomType.getDescription(),
                roomType.getBasePrice(),
                roomType.getMaxOccupancy(),
                roomType.getImageUrl()
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
        List<String> roomNames = roomBookingRepository.findByBookingId(booking.getBookingId()).stream()
                .map(roomBooking -> {
                    Room room = roomBooking.getRoom();
                    if (room == null) {
                        return "";
                    }
                    return room.getRoomName() + (room.getRoomId() != null ? " (" + room.getRoomId() + ")" : "");
                })
                .filter(value -> value != null && !value.isBlank())
                .toList();

        return new BookingSummary(
                booking.getBookingId(),
                booking.getGuest() != null ? booking.getGuest().getFullName() : "",
                booking.getGuest() != null ? booking.getGuest().getPhone() : "",
                getGuestEmail(booking),
                booking.getExpectedCheckin() != null ? booking.getExpectedCheckin().toString() : "",
                booking.getExpectedCheckout() != null ? booking.getExpectedCheckout().toString() : "",
                booking.getStatus(),
                calculateBookingTotal(booking.getBookingId()),
                roomNames
        );
    }

    private BigDecimal calculateBookingTotal(String bookingId) {
        if (bookingId == null || bookingId.isBlank()) {
            return BigDecimal.ZERO;
        }

        BigDecimal roomAmount = roomBookingRepository.findByBookingId(bookingId).stream()
                .map(RoomBooking::getPriceAtBooking)
                .filter(value -> value != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Object serviceAmount = entityManager.createNativeQuery("""
                SELECT COALESCE(SUM(TotalAmount), 0)
                FROM `Order`
                WHERE BookingId = :bookingId
                  AND UPPER(Status) <> 'CANCELLED'
                """)
                .setParameter("bookingId", bookingId)
                .getSingleResult();

        return roomAmount.add(toBigDecimal(serviceAmount));
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }
        return BigDecimal.ZERO;
    }
}
