package com.hotel.hms.modules.booking_management.entity;

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

    @Column(name = "imageURL", length = 255)
    private String imageUrl;

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

    public String getImageUrl() {
        return imageUrl;
    }
}