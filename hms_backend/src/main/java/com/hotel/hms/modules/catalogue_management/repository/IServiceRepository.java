package com.hotel.hms.modules.catalogue_management.repository;

import com.hotel.hms.modules.catalogue_management.entity.Service;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface IServiceRepository extends JpaRepository<Service, String> {

    List<Service> findByIsActiveTrue();

    Optional<Service> findByServiceName(String name);

    boolean existsByServiceName(String name);
}
