package com.hotel.hms.modules.booking_management.service;

import com.hotel.hms.modules.booking_management.dto.AccountResponse;
import com.hotel.hms.modules.booking_management.dto.CreateAccountRequest;
import com.hotel.hms.modules.booking_management.dto.UpdateAccountRequest;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import com.hotel.hms.modules.authentication.entity.Role;
import com.hotel.hms.modules.booking_management.entity.UserAccount;
import com.hotel.hms.modules.employee_management.repository.EmployeeProfileRepository;
import com.hotel.hms.modules.authentication.repository.RoleRepository;
import com.hotel.hms.modules.booking_management.repository.UserAccountRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AccountService {

    /** Roles that a Manager is allowed to manage. */
    private static final List<String> MANAGEABLE_ROLES = List.of(
            "RECEPTIONIST", "SERVICE_STAFF", "HOUSEKEEPER"
    );

    private final UserAccountRepository userRepository;
    private final RoleRepository roleRepository;
    private final EmployeeProfileRepository employeeProfileRepository;
    private final PasswordEncoder passwordEncoder;

    public AccountService(
            UserAccountRepository userRepository,
            RoleRepository roleRepository,
            EmployeeProfileRepository employeeProfileRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.employeeProfileRepository = employeeProfileRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // ========== LIST ==========

    @Transactional(readOnly = true)
    public List<AccountResponse> getAllAccounts(String search, String role) {
        List<String> targetRoles = (role != null && !role.isBlank() && MANAGEABLE_ROLES.contains(role.toUpperCase()))
                ? List.of(role.toUpperCase())
                : MANAGEABLE_ROLES;

        List<UserAccount> users;
        if (search != null && !search.isBlank()) {
            users = userRepository.searchByKeyword(search.trim(), targetRoles);
        } else {
            users = userRepository.findByRoleNames(targetRoles);
        }

        return users.stream()
                .map(this::toAccountResponse)
                .toList();
    }

    // ========== GET BY ID ==========

    @Transactional(readOnly = true)
    public AccountResponse getAccountById(String userId) {
        UserAccount user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));

        validateManageableRole(user);
        return toAccountResponse(user);
    }

    // ========== CREATE ==========

    @Transactional
    public AccountResponse createAccount(CreateAccountRequest request) {
        // Validate role
        String roleName = request.roleName().toUpperCase();
        if (!MANAGEABLE_ROLES.contains(roleName)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Role must be one of: " + String.join(", ", MANAGEABLE_ROLES)
            );
        }

        // Check duplicates
        if (userRepository.existsByUsername(request.username())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username already exists");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
        }
        if (employeeProfileRepository.existsByPhone(request.phone())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number already exists");
        }

        // Find role
        Role role = roleRepository.findByRoleName(roleName)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Role not found: " + roleName));

        // Create User
        UserAccount user = new UserAccount();
        user.setUserId(generateStaticId("USR"));
        user.setUsername(request.username().trim());
        user.setEmail(request.email().trim());
        user.setHashedPassword(passwordEncoder.encode(request.password()));
        user.setIsActive(true);
        user.setCreatedAt(LocalDateTime.now());

        Set<Role> roles = new HashSet<>();
        roles.add(role);
        user.setRoles(roles);

        user = userRepository.save(user);

        // Create EmployeeProfile
        EmployeeProfile employee = new EmployeeProfile();
        employee.setUser(user);
        employee.setEmployeeId(generateStaticId("EMP"));
        employee.setFullName(request.fullName().trim());
        employee.setPhone(request.phone().trim());
        employee.setSalary(request.salary());
        employee.setHireDate(request.hireDate() != null ? request.hireDate() : LocalDate.now());

        employeeProfileRepository.save(employee);

        // Reload to get full data
        user = userRepository.findById(user.getUserId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to reload account"));

        return toAccountResponse(user);
    }

    // ========== UPDATE ==========

    @Transactional
    public AccountResponse updateAccount(String userId, UpdateAccountRequest request) {
        UserAccount user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));

        validateManageableRole(user);

        // Update email
        if (request.email() != null && !request.email().isBlank()) {
            String newEmail = request.email().trim();
            if (!newEmail.equalsIgnoreCase(user.getEmail()) && userRepository.existsByEmail(newEmail)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
            }
            user.setEmail(newEmail);
        }

        // Update password
        if (request.password() != null && !request.password().isBlank()) {
            user.setHashedPassword(passwordEncoder.encode(request.password()));
        }

        // Update role
        if (request.roleName() != null && !request.roleName().isBlank()) {
            String newRoleName = request.roleName().toUpperCase();
            if (!MANAGEABLE_ROLES.contains(newRoleName)) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Role must be one of: " + String.join(", ", MANAGEABLE_ROLES)
                );
            }
            Role newRole = roleRepository.findByRoleName(newRoleName)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Role not found: " + newRoleName));

            Set<Role> roles = new HashSet<>();
            roles.add(newRole);
            user.setRoles(roles);
        }

        userRepository.save(user);

        // Update EmployeeProfile
        EmployeeProfile employee = user.getEmployeeProfile();
        if (employee != null) {
            if (request.fullName() != null && !request.fullName().isBlank()) {
                employee.setFullName(request.fullName().trim());
            }
            if (request.phone() != null && !request.phone().isBlank()) {
                String newPhone = request.phone().trim();
                if (!newPhone.equals(employee.getPhone()) && employeeProfileRepository.existsByPhone(newPhone)) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Phone number already exists");
                }
                employee.setPhone(newPhone);
            }
            if (request.salary() != null) {
                employee.setSalary(request.salary());
            }
            employeeProfileRepository.save(employee);
        }

        // Reload
        user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to reload account"));

        return toAccountResponse(user);
    }

    // ========== DEACTIVATE ==========

    @Transactional
    public AccountResponse deactivateAccount(String userId) {
        UserAccount user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));

        validateManageableRole(user);

        user.setIsActive(false);
        userRepository.save(user);

        return toAccountResponse(user);
    }

    // ========== ACTIVATE (RESTORE) ==========

    @Transactional
    public AccountResponse activateAccount(String userId) {
        UserAccount user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));

        validateManageableRole(user);

        user.setIsActive(true);
        userRepository.save(user);

        return toAccountResponse(user);
    }

    // ========== HELPERS ==========

    private String getCurrentUserUsername() {
        if (SecurityContextHolder.getContext().getAuthentication() == null) {
            return null;
        }
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof UserDetails) {
            return ((UserDetails) principal).getUsername();
        }
        if (principal instanceof String) {
            return (String) principal;
        }
        return null;
    }

    private void validateManageableRole(UserAccount user) {
        // Cho phép user cập nhật thông tin của chính mình (self-update)
        String currentUserId = getCurrentUserUsername(); // Trả về userId do JwtAuthFilter đặt vào principal.username
        if (currentUserId != null && currentUserId.equalsIgnoreCase(user.getUserId())) {
            return;
        }

        boolean hasManageableRole = user.getRoles().stream()
                .anyMatch(role -> MANAGEABLE_ROLES.contains(role.getRoleName()));
        if (!hasManageableRole) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Cannot manage this account — role is outside your authority"
            );
        }
    }

    private AccountResponse toAccountResponse(UserAccount user) {
        EmployeeProfile ep = user.getEmployeeProfile();
        String roleName = user.getRoles().stream()
                .map(Role::getRoleName)
                .findFirst()
                .orElse("");

        return new AccountResponse(
                user.getUserId(),
                user.getUsername(),
                user.getEmail(),
                user.getIsActive() != null && user.getIsActive(),
                user.getCreatedAt() != null ? user.getCreatedAt().toString() : "",
                ep != null ? ep.getEmployeeId() : "",
                ep != null ? ep.getFullName() : "",
                ep != null ? ep.getPhone() : "",
                ep != null ? ep.getSalary() : null,
                ep != null && ep.getHireDate() != null ? ep.getHireDate().toString() : "",
                roleName
        );
    }

    /**
     * Generate a static ID in format: XXX-NNNNNNNN (12 chars total).
     */
    private String generateStaticId(String prefix) {
        long timestamp = System.currentTimeMillis();
        long nano = Math.abs(System.nanoTime());

        String digits = String.valueOf(timestamp);
        StringBuilder sb = new StringBuilder(prefix).append('-');

        // Fill with reversed timestamp digits
        for (int i = digits.length() - 1; i >= 0 && sb.length() < 12; i--) {
            sb.append(digits.charAt(i));
        }

        // Pad remaining with nano-based random digits
        while (sb.length() < 12) {
            sb.append((char) ('0' + (int) (nano % 10)));
            nano /= 10;
        }

        return sb.substring(0, 12);
    }
}
