package com.hotel.hms.config;

import com.hotel.hms.modules.booking_management.entity.HotelService;
import com.hotel.hms.modules.booking_management.repository.HotelServiceRepository;
import java.math.BigDecimal;
import java.util.List;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class ServiceCatalogSeeder implements ApplicationRunner {
    private final HotelServiceRepository hotelServiceRepository;

    public ServiceCatalogSeeder(HotelServiceRepository hotelServiceRepository) {
        this.hotelServiceRepository = hotelServiceRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        List<HotelService> sampleServices = List.of(
                new HotelService("SRV-00000001", "Breakfast Combo", "Morning set menu for in-house guests", new BigDecimal("120000")),
                new HotelService("SRV-00000002", "Laundry Service", "Same-day laundry and ironing", new BigDecimal("80000")),
                new HotelService("SRV-00000003", "Airport Pickup", "Private airport pickup service", new BigDecimal("350000")),
                new HotelService("SRV-00000004", "Spa Relax", "60-minute spa and massage package", new BigDecimal("450000")),
                new HotelService("SRV-00000005", "Late Checkout", "Extend checkout time for the booking", new BigDecimal("200000"))
        );

        sampleServices.stream()
                .filter(service -> !hotelServiceRepository.existsById(service.getServiceId()))
                .forEach(hotelServiceRepository::save);
    }
}
