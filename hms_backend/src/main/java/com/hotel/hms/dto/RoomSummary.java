<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/dto/RoomSummary.java
package com.hotel.hms.dto;
=======
package com.hotel.hms.modules.booking_management.dto;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/dto/RoomSummary.java

public record RoomSummary(
        String roomId,
        String roomName,
        Integer floorNumber,
        String status,
        String description,
        RoomTypeSummary roomType
) {
}
