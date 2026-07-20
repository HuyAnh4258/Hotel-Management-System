package com.hotel.hms.modules.booking_management.controller;

import com.hotel.hms.modules.booking_management.dto.AccountResponse;
import com.hotel.hms.modules.booking_management.dto.CreateAccountRequest;
import com.hotel.hms.modules.booking_management.dto.UpdateAccountRequest;
import com.hotel.hms.modules.booking_management.service.AccountService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {
    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    /**
     * GET /api/accounts?search=&role=
     * List all employee accounts. Optionally filter by role and search keyword.
     */
    @GetMapping
    public ResponseEntity<List<AccountResponse>> getAllAccounts(
            @RequestParam(name = "search", required = false) String search,
            @RequestParam(name = "role", required = false) String role
    ) {
        return ResponseEntity.ok(accountService.getAllAccounts(search, role));
    }

    /**
     * GET /api/accounts/{id}
     * Get a single account by userId.
     */
    @GetMapping("/{id}")
    public ResponseEntity<AccountResponse> getAccountById(@PathVariable("id") String id) {
        return ResponseEntity.ok(accountService.getAccountById(id));
    }

    /**
     * POST /api/accounts
     * Create a new employee account (User + UserRole + EmployeeProfile).
     */
    @PostMapping
    public ResponseEntity<AccountResponse> createAccount(
            @Valid @RequestBody CreateAccountRequest request
    ) {
        AccountResponse created = accountService.createAccount(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * PUT /api/accounts/{id}
     * Update an existing account.
     */
    @PutMapping("/{id}")
    public ResponseEntity<AccountResponse> updateAccount(
            @PathVariable("id") String id,
            @RequestBody UpdateAccountRequest request
    ) {
        return ResponseEntity.ok(accountService.updateAccount(id, request));
    }

    /**
     * PUT /api/accounts/{id}/deactivate
     * Soft-delete: set IsActive = false.
     */
    @PutMapping("/{id}/deactivate")
    public ResponseEntity<AccountResponse> deactivateAccount(@PathVariable("id") String id) {
        return ResponseEntity.ok(accountService.deactivateAccount(id));
    }

    /**
     * PUT /api/accounts/{id}/activate
     * Restore account: set IsActive = true.
     */
    @PutMapping("/{id}/activate")
    public ResponseEntity<AccountResponse> activateAccount(@PathVariable("id") String id) {
        return ResponseEntity.ok(accountService.activateAccount(id));
    }
}
