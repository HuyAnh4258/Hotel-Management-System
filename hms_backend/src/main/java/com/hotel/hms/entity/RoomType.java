<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/entity/RoomType.java
package com.hotel.hms.entity;
=======
package com.hotel.hms.modules.booking_management.entity;
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/entity/RoomType.java

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;

@Entity
@Table(name = "RoomType")
public class RoomType {
    @Id
    @Column(name = "RoomTypeId", length = 12)
    private String roomTypeId;

    @Column(name = "TypeName", nullable = false, length = 50)
    private String typeName;

    @Column(name = "Description", length = 255)
    private String description;

    @Column(name = "BasePrice", nullable = false, precision = 18, scale = 2)
    private BigDecimal basePrice;

    @Column(name = "MaxOccupancy", nullable = false)
    private Integer maxOccupancy;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    public String getRoomTypeId() {
        return roomTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public Integer getMaxOccupancy() {
        return maxOccupancy;
    }

    public Boolean getIsActive() {
        return isActive;
    }
<<<<<<< Updated upstream:hms_backend/src/main/java/com/hotel/hms/entity/RoomType.java
}
=======

    public String getImageUrl() {
        return imageUrl;
    }
}
>>>>>>> Stashed changes:hms_backend/src/main/java/com/hotel/hms/modules/booking_management/entity/RoomType.java
