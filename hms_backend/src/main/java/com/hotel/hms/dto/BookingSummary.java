<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/dto/BookingSummary.java
package com.hotel.hms.dto;
=======
package com.hotel.hms.modules.booking_management.dto;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/dto/BookingSummary.java

import java.math.BigDecimal;
import java.util.List;

public record BookingSummary(
        String bookingId,
        String guestName,
        String phone,
        String email,
        String expectedCheckin,
        String expectedCheckout,
        String status,
        BigDecimal totalAmount,
        List<String> rooms
) {
    public boolean canCheckIn(String today) {
        return expectedCheckin != null && expectedCheckin.startsWith(today) && "PENDING".equalsIgnoreCase(status);
    }

    public boolean canCheckOut(String today) {
        return expectedCheckout != null && expectedCheckout.startsWith(today) && "CHECKED_IN".equalsIgnoreCase(status);
    }

    public boolean canRequestCancel() {
        return status != null
                && ("PENDING".equalsIgnoreCase(status) || "CHECKED_IN".equalsIgnoreCase(status));
    }

    public boolean isWaitingCancelApproval() {
        return "WAITING_APPROVAL".equalsIgnoreCase(status);
    }

    public boolean isCancelled() {
        return "CANCELLED".equalsIgnoreCase(status);
    }
}
