package com.hotel.hms.modules.authentication.service;

import com.hotel.hms.common.util.IdGenerator;
import com.hotel.hms.modules.authentication.dto.*;
import com.hotel.hms.modules.authentication.entity.*;
import com.hotel.hms.modules.authentication.repository.*;
import com.hotel.hms.modules.employee_management.entity.EmployeeProfile;
import com.hotel.hms.modules.employee_management.repository.EmployeeProfileRepository;
import com.hotel.hms.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepo;
    private final RoleRepository roleRepo;
    private final UserRoleRepository userRoleRepo;
    private final GuestProfileRepository guestRepo;
    private final EmployeeProfileRepository employeeRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final IdGenerator idGenerator;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String input = request.getUsername();
        User user = input.contains("@")
                ? userRepo.findByEmail(input)
                    .orElseThrow(() -> new RuntimeException("Sai tÃªn Ä‘Äƒng nháº­p hoáº·c máº­t kháº©u"))
                : userRepo.findByUsername(input)
                    .orElseThrow(() -> new RuntimeException("Sai tÃªn Ä‘Äƒng nháº­p hoáº·c máº­t kháº©u"));

        if (!user.getIsActive()) {
            throw new RuntimeException("TÃ i khoáº£n Ä‘Ã£ bá»‹ vÃ´ hiá»‡u hoÃ¡");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getHashedPassword())) {
            throw new RuntimeException("Sai tÃªn Ä‘Äƒng nháº­p hoáº·c máº­t kháº©u");
        }

        List<String> roles = userRoleRepo.findByUser_UserId(user.getUserId()).stream()
                .map(ur -> ur.getRole().getRoleName())
                .toList();

        String fullName = resolveFullName(user.getUserId(), roles);
        String token = jwtTokenProvider.generateToken(user.getUserId(), user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(user.getUserId())
                .username(user.getUsername())
                .roles(roles)
                .fullName(fullName)
                .build();
    }

    @Transactional
    public LoginResponse register(RegisterRequest request) {
        if (userRepo.existsByUsername(request.getUsername())) {
            throw new RuntimeException("TÃªn Ä‘Äƒng nháº­p Ä‘Ã£ tá»“n táº¡i");
        }
        if (userRepo.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email Ä‘Ã£ tá»“n táº¡i");
        }
        if (guestRepo.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Sá»‘ Ä‘iá»‡n thoáº¡i Ä‘Ã£ tá»“n táº¡i");
        }

        Role guestRole = roleRepo.findByRoleName("GUEST")
                .orElseThrow(() -> new RuntimeException("KhÃ´ng tÃ¬m tháº¥y role GUEST"));

        String userId = idGenerator.generateStaticId("USR", userRepo);

        User user = User.builder()
                .userId(userId)
                .username(request.getUsername())
                .email(request.getEmail())
                .hashedPassword(passwordEncoder.encode(request.getPassword()))
                .build();
        userRepo.save(user);

        userRoleRepo.save(UserRole.builder().user(user).role(guestRole).build());

        guestRepo.save(GuestProfile.builder()
                .guestId(idGenerator.generateStaticId("GST", guestRepo))
                .user(user)
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .build());

        List<String> roles = List.of("GUEST");
        String token = jwtTokenProvider.generateToken(userId, user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(userId)
                .username(user.getUsername())
                .roles(roles)
                .fullName(request.getFullName())
                .build();
    }

    @Transactional
    public void createEmployee(EmployeeCreateRequest request) {
        if (userRepo.existsByUsername(request.getUsername())) {
            throw new RuntimeException("TÃªn Ä‘Äƒng nháº­p Ä‘Ã£ tá»“n táº¡i");
        }
        if (userRepo.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email Ä‘Ã£ tá»“n táº¡i");
        }

        Role role = roleRepo.findByRoleName(request.getRole())
                .orElseThrow(() -> new RuntimeException("Role not found: " + request.getRole()));

        String userId = idGenerator.generateStaticId("USR", userRepo);
        String randomPassword = generateRandomPassword();

        userRepo.save(User.builder()
                .userId(userId)
                .username(request.getUsername())
                .email(request.getEmail())
                .hashedPassword(passwordEncoder.encode(randomPassword))
                .build());

        userRoleRepo.save(UserRole.builder().user(User.builder().userId(userId).build()).role(role).build());

        employeeRepo.save(EmployeeProfile.builder()
                .userId(userId)
                .employeeId(idGenerator.generateStaticId("EMP", employeeRepo))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .hireDate(java.time.LocalDate.now())
                .build());

        // TODO: Send email with randomPassword
    }

    public List<User> getAllUsers() {
        return userRepo.findAll();
    }

    @Transactional
    public void deactivateUser(String userId) {
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setIsActive(false);
        userRepo.save(user);
    }

    private String resolveFullName(String userId, List<String> roles) {
        if (roles.contains("GUEST")) {
            return guestRepo.findByUser_UserId(userId)
                    .map(GuestProfile::getFullName)
                    .orElse(null);
        }
        return employeeRepo.findById(userId)
                .map(EmployeeProfile::getFullName)
                .orElse(null);
    }

    private String generateRandomPassword() {
        return java.util.UUID.randomUUID().toString().substring(0, 8);
    }
}
