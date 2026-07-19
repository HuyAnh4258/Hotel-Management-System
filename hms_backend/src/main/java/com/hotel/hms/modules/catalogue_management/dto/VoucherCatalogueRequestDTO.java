package com.hotel.hms.modules.catalogue_management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VoucherCatalogueRequestDTO {

    @NotBlank(message = "Mã voucher không được trống")
    @Size(max = 50, message = "Mã voucher tối đa 50 ký tự")
    private String voucherCode;

    @DecimalMin(value = "0.0", inclusive = false, message = "Phần trăm giảm giá phải lớn hơn 0")
    @DecimalMax(value = "100.0", message = "Phần trăm giảm giá không được vượt quá 100")
    @Digits(integer = 3, fraction = 2, message = "Định dạng phần trăm không hợp lệ (tối đa 3 chữ số, 2 thập phân)")
    private BigDecimal discountPercent;

    @DecimalMin(value = "0.0", inclusive = false, message = "Số tiền giảm tối đa phải lớn hơn 0")
    @Digits(integer = 16, fraction = 2, message = "Định dạng số tiền không hợp lệ (tối đa 18 chữ số)")
    private BigDecimal maxDiscountAmount;

    @DecimalMin(value = "0.0", inclusive = false, message = "Số tiền giảm cố định phải lớn hơn 0")
    @Digits(integer = 16, fraction = 2, message = "Định dạng số tiền không hợp lệ")
    private BigDecimal discountAmount;

    @DecimalMin(value = "0.0", inclusive = false, message = "Giá trị đặt phòng tối thiểu phải lớn hơn 0")
    @Digits(integer = 16, fraction = 2, message = "Định dạng số tiền không hợp lệ")
    private BigDecimal minBookingValue;

    @NotNull(message = "Ngày hết hạn không được trống")
    @Future(message = "Ngày hết hạn phải ở tương lai")
    private LocalDateTime expiryTime;
}
