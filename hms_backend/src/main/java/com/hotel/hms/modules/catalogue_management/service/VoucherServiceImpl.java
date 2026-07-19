package com.hotel.hms.modules.catalogue_management.service;

import com.hotel.hms.common.util.AuditLogService;
import com.hotel.hms.common.util.IdGenerator;
import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueRequestDTO;
import com.hotel.hms.modules.catalogue_management.dto.VoucherCatalogueResponseDTO;
import com.hotel.hms.modules.booking_management.entity.Voucher;
import com.hotel.hms.modules.catalogue_management.repository.IVoucherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VoucherServiceImpl implements IVoucherService {

    private final IVoucherRepository voucherRepo;
    private final IdGenerator idGenerator;
    private final AuditLogService auditLogService;

    // ─── CREATE ─────────────────────────────────────────────────

    @Override
    @Transactional
    public VoucherCatalogueResponseDTO createVoucherItem(VoucherCatalogueRequestDTO request, String employeeId) {
        if (voucherRepo.existsByVoucherCode(request.getVoucherCode())) {
            throw new RuntimeException("Mã voucher đã tồn tại: " + request.getVoucherCode());
        }

        Voucher voucher = Voucher.builder()
                .voucherId(idGenerator.generateStaticId("VCH", voucherRepo))
                .voucherCode(request.getVoucherCode())
                .discountPercent(request.getDiscountPercent())
                .maxDiscountAmount(request.getMaxDiscountAmount())
                .discountAmount(request.getDiscountAmount())
                .minBookingValue(request.getMinBookingValue())
                .expiryTime(request.getExpiryTime())
                .isActive(true)
                .build();

        VoucherCatalogueResponseDTO response = toResponse(voucherRepo.save(voucher));
        auditLogService.logAsync("CREATE", response);
        return response;
    }

    // ─── READ ───────────────────────────────────────────────────

    @Override
    public List<VoucherCatalogueResponseDTO> getAllItems() {
        return voucherRepo.findByIsActiveTrue().stream().map(this::toResponse).toList();
    }

    @Override
    public VoucherCatalogueResponseDTO getVoucherById(String id) {
        return toResponse(findVoucherOrThrow(id));
    }

    // ─── UPDATE ─────────────────────────────────────────────────

    @Override
    @Transactional
    public VoucherCatalogueResponseDTO updateVoucherDetails(String id, VoucherCatalogueRequestDTO request) {
        Voucher voucher = findVoucherOrThrow(id);

        if (!voucher.getIsActive()) {
            throw new RuntimeException("Voucher đã bị vô hiệu hóa, không thể cập nhật hoặc khôi phục.");
        }

        voucherRepo.findByVoucherCode(request.getVoucherCode()).ifPresent(existing -> {
            if (!existing.getVoucherId().equals(id)) {
                throw new RuntimeException("Mã voucher đã tồn tại: " + request.getVoucherCode());
            }
        });

        voucher.setVoucherCode(request.getVoucherCode());
        voucher.setDiscountPercent(request.getDiscountPercent());
        voucher.setMaxDiscountAmount(request.getMaxDiscountAmount());
        voucher.setDiscountAmount(request.getDiscountAmount());
        voucher.setMinBookingValue(request.getMinBookingValue());
        voucher.setExpiryTime(request.getExpiryTime());

        VoucherCatalogueResponseDTO response = toResponse(voucherRepo.save(voucher));
        auditLogService.logAsync("UPDATE", response);
        return response;
    }

    // ─── SOFT DELETE ─────────────────────────────────────────────

    @Override
    @Transactional
    public void deactivateVoucherItem(String id) {
        Voucher voucher = findVoucherOrThrow(id);
        voucher.setIsActive(false);
        voucherRepo.save(voucher);
    }

    // ─── PRIVATE ─────────────────────────────────────────────────

    private VoucherCatalogueResponseDTO toResponse(Voucher voucher) {
        return VoucherCatalogueResponseDTO.builder()
                .voucherId(voucher.getVoucherId())
                .voucherCode(voucher.getVoucherCode())
                .discountPercent(voucher.getDiscountPercent())
                .maxDiscountAmount(voucher.getMaxDiscountAmount())
                .discountAmount(voucher.getDiscountAmount())
                .minBookingValue(voucher.getMinBookingValue())
                .expiryTime(voucher.getExpiryTime())
                .isActive(voucher.getIsActive())
                .build();
    }

    private Voucher findVoucherOrThrow(String id) {
        return voucherRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy voucher: " + id));
    }
}
