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
    private final OtpCodeRepository otpCodeRepo;
    private final EmailService emailService;

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

        List<UserRole> userRoles = userRoleRepo.findByUser_UserId(user.getUserId());
        List<String> roles = userRoles.stream()
                .map(ur -> ur.getRole().getRoleName())
                .toList();
        List<String> roleIds = userRoles.stream()
                .map(ur -> ur.getRole().getRoleId())
                .toList();

        GuestProfile guestProfile = guestRepo.findByUser_UserId(user.getUserId()).orElse(null);
        String fullName = guestProfile != null ? guestProfile.getFullName() : null;
        if (fullName == null) {
            fullName = resolveFullName(user.getUserId(), roles);
        }
        String phone = guestProfile != null ? guestProfile.getPhone() : null;
        String email = user.getEmail();
        String token = jwtTokenProvider.generateToken(user.getUserId(), user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(user.getUserId())
                .username(user.getUsername())
                .roles(roles)
                .roleIds(roleIds)
                .fullName(fullName)
                .phone(phone)
                .email(email)
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
        List<String> roleIds = List.of(guestRole.getRoleId());
        String token = jwtTokenProvider.generateToken(userId, user.getUsername(), roles);

        return LoginResponse.builder()
                .accessToken(token)
                .userId(userId)
                .username(user.getUsername())
                .roles(roles)
                .roleIds(roleIds)
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .email(request.getEmail())
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

    @Transactional
    public void requestForgotPasswordOtp(ForgotPasswordRequest request) {
        String email = request.getEmail().trim();
        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("KhÃ´ng tÃ¬m tháº¥y tÃ i khoáº£n liÃªn káº¿t vá»›i email nÃ y"));

        // Generate 6-digit numeric OTP
        String otp = String.valueOf((int) ((Math.random() * 900000) + 100000));
        java.time.LocalDateTime expireTime = java.time.LocalDateTime.now().plusMinutes(5);

        OtpCode otpCode = otpCodeRepo.findByEmail(email).orElse(null);
        if (otpCode == null) {
            otpCode = OtpCode.builder().email(email).build();
        }
        otpCode.setOtp(otp);
        otpCode.setExpireTime(expireTime);
        otpCodeRepo.save(otpCode);

        emailService.sendOtpEmail(email, otp);
    }

    public void verifyForgotPasswordOtp(ForgotPasswordVerifyRequest request) {
        String email = request.getEmail().trim();
        String otp = request.getOtp().trim();

        OtpCode otpCode = otpCodeRepo.findByEmailAndOtp(email, otp)
                .orElseThrow(() -> new RuntimeException("MÃ£ OTP khÃ´ng Ä‘Ãºng hoáº·c khÃ´ng tá»“n táº¡i"));

        if (otpCode.getExpireTime().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("MÃ£ OTP Ä‘Ã£ háº¿t hiá»‡u lá»±c");
        }
    }

    @Transactional
    public void resetPassword(ForgotPasswordResetRequest request) {
        String email = request.getEmail().trim();
        String otp = request.getOtp().trim();

        OtpCode otpCode = otpCodeRepo.findByEmailAndOtp(email, otp)
                .orElseThrow(() -> new RuntimeException("MÃ£ OTP khÃ´ng Ä‘Ãºng hoáº·c khÃ´ng tá»“n táº¡i"));

        if (otpCode.getExpireTime().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("MÃ£ OTP Ä‘Ã£ háº¿t hiá»‡u lá»±c");
        }

        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("KhÃ´ng tÃ¬m tháº¥y tÃ i khoáº£n liÃªn káº¿t vá»›i email nÃ y"));

        user.setHashedPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepo.save(user);

        // Delete OTP after successful use
        otpCodeRepo.delete(otpCode);
    }

    private String generateRandomPassword() {
        return java.util.UUID.randomUUID().toString().substring(0, 8);
    }
}
