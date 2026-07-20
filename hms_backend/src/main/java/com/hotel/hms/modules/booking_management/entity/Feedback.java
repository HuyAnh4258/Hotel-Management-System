package com.hotel.hms.modules.booking_management.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "Feedback")
public class Feedback {
    @Id
    @Column(name = "FeedbackId", length = 20)
    private String feedbackId;

    @OneToOne(optional = false)
    @JoinColumn(name = "BookingId")
    private Booking booking;

    @Column(name = "Rating", nullable = false)
    private Byte rating;

    @Column(name = "Comment", length = 1000)
    private String comment;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    protected Feedback() {
    }

    public Feedback(String feedbackId, Booking booking, Byte rating, String comment, LocalDateTime createdAt) {
        this.feedbackId = feedbackId;
        this.booking = booking;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    public String getFeedbackId() {
        return feedbackId;
    }

    public Booking getBooking() {
        return booking;
    }

    public Byte getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setRating(Byte rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
