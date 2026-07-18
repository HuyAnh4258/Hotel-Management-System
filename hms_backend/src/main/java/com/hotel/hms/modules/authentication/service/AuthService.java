package com.hotel.hms.modules.authentication.service;

import com.hotel.hms.common.util.IdGenerator;
import com.hotel.hms.entity.GuestProfile;
import com.hotel.hms.modules.authentication.dto.*;
import com.hotel.hms.modules.authentication.entity.Role;
import com.hotel.hms.modules.authentication.entity.User;
import com.hotel.hms.modules.authentication.entity.UserRole;
import com.hotel.hms.modules.authentication.repository.RoleRepository;
import com.hotel.hms.modules.authentication.repository.UserRepository;
import com.hotel.hms.modules.authentication.repository.UserRoleRepository;
import com.hotel.hms.repository.GuestProfileRepository;
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
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final IdGenerator idGenerator;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String input = request.getUsername();
        User user = input.contains("@")
                ? userRepo.findByEmail(input)
                    .orElseThrow(() -> new RuntimeException("Sai tên đăng nhập hoặc mật khẩu"))
                : userRepo.findByUsername(input)
                    .orElseThrow(() -> new RuntimeException("Sai tên đăng nhập hoặc mật khẩu"));

        if (!user.getIsActive()) {
            throw new RuntimeException("Tài khoản đã bị vô hiệu hoá");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getHashedPassword())) {
            throw new RuntimeException("Sai tên đăng nhập hoặc mật khẩu");
        }

        List<UserRole> userRoles = userRoleRepo.findByUser_UserId(user.getUserId());
        List<String> roles = userRoles.stream()
                .map(ur -> ur.getRole().getRoleName())
                .toList();
        List<String> roleIds = userRoles.stream()
                .map(ur -> ur.getRole().getRoleId())
                .toList();

        String fullName = resolveFullName(user.getUserId(), roles);
        String token = jwtTokenProvider.generateToken(user.getUserId(), user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(user.getUserId())
                .username(user.getUsername())
                .roles(roles)
                .roleIds(roleIds)
                .fullName(fullName)
                .build();
    }

    @Transactional
    public LoginResponse register(RegisterRequest request) {
        if (userRepo.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Tên đăng nhập đã tồn tại");
        }
        if (userRepo.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã tồn tại");
        }
        if (guestRepo.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Số điện thoại đã tồn tại");
        }

        Role guestRole = roleRepo.findByRoleName("GUEST")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy role GUEST"));

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
                .userId(userId)
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .build());

        List<String> roles = List.of("GUEST");
        List<String> roleIds = List.of(guestRole.getRoleId());
        String token = jwtTokenProvider.generateToken(userId, user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(userId)
                .username(user.getUsername())
                .roles(roles)
                .roleIds(roleIds)
                .fullName(request.getFullName())
                .build();
    }

    @Transactional
    public void createEmployee(EmployeeCreateRequest request) {
        if (userRepo.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Tên đăng nhập đã tồn tại");
        }
        if (userRepo.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã tồn tại");
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
        return guestRepo.findByUserId(userId)
                .map(GuestProfile::getFullName)
                .orElse(null);
    }

    private String generateRandomPassword() {
        return java.util.UUID.randomUUID().toString().substring(0, 8);
    }
}
