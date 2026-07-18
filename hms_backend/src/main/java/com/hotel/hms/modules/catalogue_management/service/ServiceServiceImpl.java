package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.entity.Service;
import com.hotel.hms.modules.catalogue_management.repository.IServiceRepository;
import com.hotel.hms.common.util.IdGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class ServiceServiceImpl {

    private final IServiceRepository serviceRepo;
    private final IdGenerator idGenerator;

    public List<ServiceResponseDTO> getAll() {
        return serviceRepo.findByIsActiveTrue().stream().map(this::toResponse).toList();
    }

    public ServiceResponseDTO getById(String id) {
        return toResponse(findOrThrow(id));
    }

    @Transactional
    public ServiceResponseDTO create(ServiceRequestDTO request) {
        if (serviceRepo.existsByServiceName(request.getServiceName())) {
            throw new RuntimeException("Tên dịch vụ đã tồn tại");
        }
        Service svc = Service.builder()
                .serviceId(idGenerator.generateStaticId("SRV", serviceRepo))
                .serviceName(request.getServiceName())
                .description(request.getDescription())
                .unitPrice(request.getUnitPrice())
                .build();
        return toResponse(serviceRepo.save(svc));
    }

    @Transactional
    public ServiceResponseDTO update(String id, ServiceRequestDTO request) {
        Service svc = findOrThrow(id);
        serviceRepo.findByServiceName(request.getServiceName()).ifPresent(existing -> {
            if (!existing.getServiceId().equals(id)) {
                throw new RuntimeException("Tên dịch vụ đã tồn tại");
            }
        });
        svc.setServiceName(request.getServiceName());
        svc.setDescription(request.getDescription());
        svc.setUnitPrice(request.getUnitPrice());
        return toResponse(serviceRepo.save(svc));
    }

    @Transactional
    public ServiceResponseDTO updatePrice(String id, Number unitPrice) {
        Service svc = findOrThrow(id);
        svc.setUnitPrice(new java.math.BigDecimal(unitPrice.toString()));
        return toResponse(serviceRepo.save(svc));
    }

    @Transactional
    public void deactivate(String id) {
        Service svc = findOrThrow(id);
        svc.setIsActive(false);
        serviceRepo.save(svc);
    }

    private ServiceResponseDTO toResponse(Service svc) {
        return ServiceResponseDTO.builder()
                .serviceId(svc.getServiceId())
                .serviceName(svc.getServiceName())
                .description(svc.getDescription())
                .unitPrice(svc.getUnitPrice())
                .isActive(svc.getIsActive())
                .createdAt(svc.getCreatedAt())
                .build();
    }

    private Service findOrThrow(String id) {
        return serviceRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy dịch vụ"));
    }
}
