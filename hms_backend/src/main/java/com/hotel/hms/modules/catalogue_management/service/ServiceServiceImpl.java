package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.modules.catalogue_management.dto.*;
import com.hotel.hms.modules.catalogue_management.entity.Service;
import com.hotel.hms.modules.catalogue_management.repository.IServiceRepository;
import com.hotel.hms.common.util.IdGenerator;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class ServiceServiceImpl {

    private final IServiceRepository serviceRepo;
    private final IdGenerator idGenerator;
    private final SimpMessagingTemplate messagingTemplate;
    private final com.hotel.hms.modules.catalogue_management.repository.ServiceInventoryRecipeRepository recipeRepo;
    private final com.hotel.hms.modules.catalogue_management.repository.IInventoryRepository inventoryRepo;

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
                .isComposite(request.getIsComposite() != null ? request.getIsComposite() : false)
                .build();
        Service saved = serviceRepo.save(svc);
        if (request.getIsComposite() != null && request.getIsComposite()) {
            saveRecipeItems(saved, request.getRecipeItems());
        }
        ServiceResponseDTO response = toResponse(saved);
        broadcastServiceUpdate(response);
        return response;
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
        svc.setIsComposite(request.getIsComposite() != null ? request.getIsComposite() : false);
        Service saved = serviceRepo.save(svc);
        if (request.getIsComposite() != null && request.getIsComposite()) {
            saveRecipeItems(saved, request.getRecipeItems());
        } else {
            List<com.hotel.hms.modules.catalogue_management.entity.ServiceInventoryRecipe> existing = 
                recipeRepo.findByService_ServiceId(saved.getServiceId());
            recipeRepo.deleteAll(existing);
        }
        ServiceResponseDTO response = toResponse(saved);
        broadcastServiceUpdate(response);
        return response;
    }

    private void saveRecipeItems(Service service, List<ServiceRequestDTO.RecipeItemDTO> items) {
        List<com.hotel.hms.modules.catalogue_management.entity.ServiceInventoryRecipe> existing = 
            recipeRepo.findByService_ServiceId(service.getServiceId());
        recipeRepo.deleteAll(existing);

        if (items != null && !items.isEmpty()) {
            for (ServiceRequestDTO.RecipeItemDTO itemDto : items) {
                com.hotel.hms.modules.catalogue_management.entity.InventoryItem invItem = 
                    inventoryRepo.findById(itemDto.getItemId())
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy vật tư: " + itemDto.getItemId()));
                
                com.hotel.hms.modules.catalogue_management.entity.ServiceInventoryRecipe recipe = 
                    com.hotel.hms.modules.catalogue_management.entity.ServiceInventoryRecipe.builder()
                        .service(service)
                        .inventoryItem(invItem)
                        .quantityRequired(itemDto.getQuantityRequired())
                        .build();
                recipeRepo.save(recipe);
            }
        }
    }

    @Transactional
    public ServiceResponseDTO updatePrice(String id, Number unitPrice) {
        Service svc = findOrThrow(id);
        svc.setUnitPrice(new java.math.BigDecimal(unitPrice.toString()));
        ServiceResponseDTO response = toResponse(serviceRepo.save(svc));
        broadcastServiceUpdate(response);
        return response;
    }

    @Transactional
    public void deactivate(String id) {
        Service svc = findOrThrow(id);
        svc.setIsActive(false);
        ServiceResponseDTO response = toResponse(serviceRepo.save(svc));
        broadcastServiceUpdate(response);
    }

    private ServiceResponseDTO toResponse(Service svc) {
        List<ServiceResponseDTO.RecipeItemResponseDTO> recipeList = null;
        if (svc.getIsComposite() != null && svc.getIsComposite()) {
            recipeList = recipeRepo.findByService_ServiceId(svc.getServiceId()).stream()
                .map(r -> ServiceResponseDTO.RecipeItemResponseDTO.builder()
                    .itemId(r.getInventoryItem().getItemId())
                    .itemName(r.getInventoryItem().getItemName())
                    .quantityRequired(r.getQuantityRequired())
                    .unitPrice(r.getInventoryItem().getUnitPrice())
                    .build())
                .toList();
        }
        return ServiceResponseDTO.builder()
                .serviceId(svc.getServiceId())
                .serviceName(svc.getServiceName())
                .description(svc.getDescription())
                .unitPrice(svc.getUnitPrice())
                .isComposite(svc.getIsComposite())
                .recipeItems(recipeList)
                .isActive(svc.getIsActive())
                .createdAt(svc.getCreatedAt())
                .build();
    }

    private Service findOrThrow(String id) {
        return serviceRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy dịch vụ"));
    }

    private void broadcastServiceUpdate(ServiceResponseDTO response) {
        if (org.springframework.transaction.support.TransactionSynchronizationManager.isSynchronizationActive()) {
            org.springframework.transaction.support.TransactionSynchronizationManager.registerSynchronization(
                new org.springframework.transaction.support.TransactionSynchronization() {
                    @Override
                    public void afterCommit() {
                        try {
                            messagingTemplate.convertAndSend("/topic/service-updates", response);
                        } catch (Exception e) {
                        }
                    }
                }
            );
        } else {
            try {
                messagingTemplate.convertAndSend("/topic/service-updates", response);
            } catch (Exception e) {
            }
        }
    }
}
