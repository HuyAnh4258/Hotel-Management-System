package com.hotel.hms.modules.booking_management.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceRequestDTO {
    private String roomId;
    private String reporterId;
    private String issueType;
    private String description;
    // We can accept image but for now DB doesn't have an Image URL field. 
    // We will just process the text data.
}
