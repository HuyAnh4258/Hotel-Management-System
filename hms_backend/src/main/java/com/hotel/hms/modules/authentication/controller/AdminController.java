package com.hotel.hms.modules.authentication.controller;

import com.hotel.hms.modules.authentication.dto.EmployeeCreateRequest;
import com.hotel.hms.modules.authentication.entity.User;
import com.hotel.hms.modules.authentication.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AuthService authService;

    @PostMapping("/employees")
    public ResponseEntity<Void> createEmployee(@Valid @RequestBody EmployeeCreateRequest request) {
        authService.createEmployee(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(authService.getAllUsers());
    }

    @PatchMapping("/users/{id}/deactivate")
    public ResponseEntity<Void> deactivateUser(@PathVariable String id) {
        authService.deactivateUser(id);
        return ResponseEntity.noContent().build();
    }
}
