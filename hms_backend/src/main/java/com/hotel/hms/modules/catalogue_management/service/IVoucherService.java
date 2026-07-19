package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueRequestDTO;
import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueResponseDTO;
import java.util.List;

public interface IVoucherService {

    VoucherCatalogueResponseDTO createVoucherItem(VoucherCatalogueRequestDTO request, String employeeId);

    List<VoucherCatalogueResponseDTO> getAllItems();

    VoucherCatalogueResponseDTO getVoucherById(String id);

    VoucherCatalogueResponseDTO updateVoucherDetails(String id, VoucherCatalogueRequestDTO request);

    void deactivateVoucherItem(String id);
}
