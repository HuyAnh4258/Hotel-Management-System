package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.RoomDTO;
import com.hotel.hms.modules.booking_management.entity.Room;
import com.hotel.hms.modules.booking_management.repository.RoomRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RoomService {

    private final RoomRepository roomRepository;

    public RoomService(RoomRepository roomRepository) {
        this.roomRepository = roomRepository;
    }

    @Transactional(readOnly = true)
    public List<RoomDTO> getRoomsByStatus(String status) {
        List<Room> rooms;
        if (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status)) {
            rooms = roomRepository.findByIsActiveTrue();
        } else {
            rooms = roomRepository.findByIsActiveTrueAndStatusIn(List.of(status.toUpperCase()));
        }

        return rooms.stream().map(this::mapToDTO).toList();
    }

    @Transactional
    public RoomDTO updateRoomStatus(String roomId, String newStatus) {
        if (newStatus == null || newStatus.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status is required");
        }

        Room room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));

        room.setStatus(newStatus.toUpperCase());
        room = roomRepository.save(room);

        return mapToDTO(room);
    }

    private RoomDTO mapToDTO(Room room) {
        return new RoomDTO(
                room.getRoomId(),
                room.getRoomName(),
                room.getRoomType() != null ? room.getRoomType().getTypeName() : "Unknown",
                room.getFloorNumber(),
                room.getStatus(),
                room.getDescription()
        );
    }
}
