<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/dto/CreateBookingRequest.java
package com.hotel.hms.dto;
=======
package com.hotel.hms.modules.booking_management.dto;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/dto/CreateBookingRequest.java

import java.time.LocalDate;
import java.util.List;

public record CreateBookingRequest(
        String guestName,
        String email,
        String phone,
        LocalDate expectedCheckin,
        LocalDate expectedCheckout,
        List<String> roomIds,
        String voucherCode,
        Integer guests
) {
}