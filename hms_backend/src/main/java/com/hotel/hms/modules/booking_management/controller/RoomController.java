package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.entity.Room;
import com.hotel.hms.modules.booking_management.entity.RoomType;
import com.hotel.hms.modules.booking_management.dto.RoomDTO;
import com.hotel.hms.modules.booking_management.repository.RoomRepository;
import com.hotel.hms.modules.booking_management.repository.RoomTypeRepository;
import com.hotel.hms.modules.booking_management.service.RoomService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {

    private final RoomService roomService;
    private final RoomRepository roomRepository;
    private final RoomTypeRepository roomTypeRepository;

    public RoomController(
            RoomService roomService,
            RoomRepository roomRepository,
            RoomTypeRepository roomTypeRepository
    ) {
        this.roomService = roomService;
        this.roomRepository = roomRepository;
        this.roomTypeRepository = roomTypeRepository;
    }

    @GetMapping
    public ResponseEntity<List<RoomDTO>> getRooms(@RequestParam(name = "status", required = false) String status) {
        return ResponseEntity.ok(roomService.getRoomsByStatus(status));
    }

    @GetMapping("/all")
    public ResponseEntity<List<Room>> getAllRooms() {
        return ResponseEntity.ok(roomRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Room> createRoom(@RequestBody Map<String, Object> payload) {
        String roomId = (String) payload.get("roomId");
        if (roomRepository.existsById(roomId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Room ID already exists");
        }

        Room room = new Room();
        room.setRoomId(roomId);
        room.setRoomName((String) payload.get("roomName"));
        room.setFloorNumber(Integer.parseInt(payload.get("floorNumber").toString()));
        room.setStatus(payload.getOrDefault("status", "AVAILABLE").toString().toUpperCase());
        room.setDescription((String) payload.get("description"));
        room.setIsActive(true);

        String roomTypeId = (String) payload.get("roomTypeId");
        RoomType rt = roomTypeRepository.findById(roomTypeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "RoomType not found"));
        room.setRoomType(rt);

        return ResponseEntity.status(HttpStatus.CREATED).body(roomRepository.save(room));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Room> updateRoom(
            @PathVariable("id") String id,
            @RequestBody Map<String, Object> payload
    ) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));

        if (payload.containsKey("roomName")) room.setRoomName((String) payload.get("roomName"));
        if (payload.containsKey("floorNumber")) room.setFloorNumber(Integer.parseInt(payload.get("floorNumber").toString()));
        if (payload.containsKey("status")) room.setStatus(payload.get("status").toString().toUpperCase());
        if (payload.containsKey("description")) room.setDescription((String) payload.get("description"));

        if (payload.containsKey("roomTypeId")) {
            String roomTypeId = (String) payload.get("roomTypeId");
            RoomType rt = roomTypeRepository.findById(roomTypeId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "RoomType not found"));
            room.setRoomType(rt);
        }

        return ResponseEntity.ok(roomRepository.save(room));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<RoomDTO> updateRoomStatus(
            @PathVariable("id") String id,
            @RequestBody Map<String, String> payload
    ) {
        String newStatus = payload.get("status");
        return ResponseEntity.ok(roomService.updateRoomStatus(id, newStatus));
    }

    @PutMapping("/{id}/deactivate")
    public ResponseEntity<Room> deactivateRoom(@PathVariable("id") String id) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));
        room.setIsActive(false);
        return ResponseEntity.ok(roomRepository.save(room));
    }

    @PutMapping("/{id}/activate")
    public ResponseEntity<Room> activateRoom(@PathVariable("id") String id) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Room not found"));
        room.setIsActive(true);
        return ResponseEntity.ok(roomRepository.save(room));
    }
}
