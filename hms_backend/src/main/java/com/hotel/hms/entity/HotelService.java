package com.hotel.hms.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;

@Entity
@Table(name = "Service")
public class HotelService {
    @Id
    @Column(name = "ServiceId", length = 12)
    private String serviceId;

    @Column(name = "ServiceName", nullable = false, length = 100)
    private String serviceName;

    @Column(name = "Description", length = 500)
    private String description;

    @Column(name = "Price", nullable = false, precision = 18, scale = 2)
    private BigDecimal price;

    @Column(name = "IsActive", nullable = false)
    private Boolean isActive = true;

    protected HotelService() {
    }

    public HotelService(String serviceId, String serviceName, String description, BigDecimal price) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.description = description;
        this.price = price;
        this.isActive = true;
    }

    public String getServiceId() {
        return serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public Boolean getIsActive() {
        return isActive;
    }
}
