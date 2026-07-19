<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/dto/RoomTypeSummary.java
package com.hotel.hms.dto;
=======
package com.hotel.hms.modules.booking_management.dto;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/dto/RoomTypeSummary.java

import java.math.BigDecimal;

public record RoomTypeSummary(
        String roomTypeId,
        String typeName,
        String description,
        BigDecimal basePrice,
        Integer maxOccupancy
) {
}
