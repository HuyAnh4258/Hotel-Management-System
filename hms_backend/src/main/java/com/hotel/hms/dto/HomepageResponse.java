<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/dto/HomepageResponse.java
package com.hotel.hms.dto;
=======
package com.hotel.hms.modules.booking_management.dto;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/dto/HomepageResponse.java

import java.util.List;

public record HomepageResponse(
        List<RoomTypeSummary> roomTypes,
        List<RoomSummary> availableRooms,
        List<BookingSummary> recentBookings
) {
}
