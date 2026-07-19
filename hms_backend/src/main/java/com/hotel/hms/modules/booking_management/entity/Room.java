package com.hotel.hms.modules.booking_management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "Room")
public class Room {
    @Id
    @Column(name = "RoomId", length = 5)
    private String roomId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "RoomTypeId")
    private RoomType roomType;

    @Column(name = "RoomName", nullable = false, length = 50)
    private String roomName;

    @Column(name = "FloorNumber", nullable = false)
    private Integer floorNumber;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "Description", length = 255)
    private String description;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    public String getRoomId() {
        return roomId;
    }

    public RoomType getRoomType() {
        return roomType;
    }

    public String getRoomName() {
        return roomName;
    }

    public Integer getFloorNumber() {
        return floorNumber;
    }

    public String getStatus() {
        return status;
    }

    public String getDescription() {
        return description;
    }

    public Boolean getIsActive() {
        return isActive;
    }
}
