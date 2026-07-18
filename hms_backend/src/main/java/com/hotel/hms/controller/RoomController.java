package com.hotel.hms.controller;

import com.hotel.hms.dto.RoomDTO;
import com.hotel.hms.service.RoomService;
import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {

    private final RoomService roomService;

    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    @GetMapping
    public ResponseEntity<List<RoomDTO>> getRooms(@RequestParam(name = "status", required = false) String status) {
        return ResponseEntity.ok(roomService.getRoomsByStatus(status));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<RoomDTO> updateRoomStatus(
            @PathVariable("id") String id,
            @RequestBody Map<String, String> payload
    ) {
        String newStatus = payload.get("status");
        return ResponseEntity.ok(roomService.updateRoomStatus(id, newStatus));
    }
}
