package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.entity.RoomType;
import com.hotel.hms.modules.booking_management.repository.RoomTypeRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/room-types")
public class RoomTypeController {

    private final RoomTypeRepository roomTypeRepository;

    public RoomTypeController(RoomTypeRepository roomTypeRepository) {
        this.roomTypeRepository = roomTypeRepository;
    }

    @GetMapping
    public ResponseEntity<List<RoomType>> getAllRoomTypes() {
        return ResponseEntity.ok(roomTypeRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<RoomType> createRoomType(@RequestBody Map<String, Object> payload) {
        RoomType rt = new RoomType();
        // Generate static ID similar to user
        rt.setRoomTypeId("RT-" + (System.currentTimeMillis() % 100000000));
        rt.setTypeName((String) payload.get("typeName"));
        rt.setDescription((String) payload.get("description"));
        rt.setBasePrice(new BigDecimal(payload.get("basePrice").toString()));
        rt.setMaxOccupancy(Integer.parseInt(payload.get("maxOccupancy").toString()));
        rt.setIsActive(true);
        if (payload.containsKey("imageUrl")) {
            rt.setImageUrl((String) payload.get("imageUrl"));
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(roomTypeRepository.save(rt));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RoomType> updateRoomType(
            @PathVariable("id") String id,
            @RequestBody Map<String, Object> payload
    ) {
        RoomType rt = roomTypeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RoomType not found"));

        if (payload.containsKey("typeName")) rt.setTypeName((String) payload.get("typeName"));
        if (payload.containsKey("description")) rt.setDescription((String) payload.get("description"));
        if (payload.containsKey("basePrice")) rt.setBasePrice(new BigDecimal(payload.get("basePrice").toString()));
        if (payload.containsKey("maxOccupancy")) rt.setMaxOccupancy(Integer.parseInt(payload.get("maxOccupancy").toString()));
        if (payload.containsKey("imageUrl")) rt.setImageUrl((String) payload.get("imageUrl"));

        return ResponseEntity.ok(roomTypeRepository.save(rt));
    }

    @PutMapping("/{id}/deactivate")
    public ResponseEntity<RoomType> deactivateRoomType(@PathVariable("id") String id) {
        RoomType rt = roomTypeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RoomType not found"));
        rt.setIsActive(false);
        return ResponseEntity.ok(roomTypeRepository.save(rt));
    }

    @PutMapping("/{id}/activate")
    public ResponseEntity<RoomType> activateRoomType(@PathVariable("id") String id) {
        RoomType rt = roomTypeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RoomType not found"));
        rt.setIsActive(true);
        return ResponseEntity.ok(roomTypeRepository.save(rt));
    }
}