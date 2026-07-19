package com.hotel.hms.modules.booking_management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;

@Entity
@Table(name = "RoomBooking")
public class RoomBooking {
    @Id
    @Column(name = "RoomBookingId", length = 20)
    private String roomBookingId;

    @ManyToOne(optional = false)
    @JoinColumn(name = "RoomId")
    private Room room;

    @ManyToOne(optional = false)
    @JoinColumn(name = "BookingId")
    private Booking booking;

    @Column(name = "PriceAtBooking", nullable = false, precision = 18, scale = 2)
    private BigDecimal priceAtBooking;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    public String getRoomBookingId() {
        return roomBookingId;
    }

    public Room getRoom() {
        return room;
    }

    public Booking getBooking() {
        return booking;
    }

    public BigDecimal getPriceAtBooking() {
        return priceAtBooking;
    }

    public String getStatus() {
        return status;
    }
}