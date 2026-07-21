package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.MaintenanceRequestDTO;
import com.hotel.hms.modules.booking_management.entity.MaintenanceRequest;
import com.hotel.hms.modules.booking_management.entity.Room;
import com.hotel.hms.modules.booking_management.repository.MaintenanceRequestRepository;
import com.hotel.hms.modules.booking_management.repository.RoomRepository;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import com.hotel.hms.modules.employee_management.repository.EmployeeProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class MaintenanceRequestService {
    
    private final MaintenanceRequestRepository maintenanceRequestRepository;
    private final RoomRepository roomRepository;
    private final EmployeeProfileRepository employeeProfileRepository;

    public MaintenanceRequestService(
            MaintenanceRequestRepository maintenanceRequestRepository,
            RoomRepository roomRepository,
            EmployeeProfileRepository employeeProfileRepository) {
        this.maintenanceRequestRepository = maintenanceRequestRepository;
        this.roomRepository = roomRepository;
        this.employeeProfileRepository = employeeProfileRepository;
    }

    @Transactional
    public MaintenanceRequest createMaintenanceRequest(MaintenanceRequestDTO dto) {
        Room room = roomRepository.findById(dto.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));
        
        EmployeeProfile reporter = employeeProfileRepository.findById(dto.getReporterId())
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        // Format RequestId: MNT-YYMMDDHHMMSS-HHHH
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmmss"));
        String requestId = "MNT-" + timestamp + "-0000";

        MaintenanceRequest request = MaintenanceRequest.builder()
                .requestId(requestId)
                .reporter(reporter)
                .room(room)
                .description(dto.getIssueType() + " - " + dto.getDescription())
                .status("PENDING")
                .build();

        // Update room status
        room.setStatus("MAINTENANCE");
        roomRepository.save(room);

        return maintenanceRequestRepository.save(request);
    }
}
