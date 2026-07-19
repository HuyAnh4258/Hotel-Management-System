package com.hotel.hms.modules.authentication.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendOtpEmail(String toEmail, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("FPT Golden <your-email@gmail.com>"); // Thay bằng email của bạn
        message.setTo(toEmail);
        message.setSubject("FPT Golden - Mã xác thực OTP");
        message.setText("Chào bạn,\n\n"
                + "Bạn vừa yêu cầu khôi phục mật khẩu cho tài khoản FPT Golden của mình.\n\n"
                + "Mã xác thực OTP của bạn là: " + otp + "\n"
                + "Lưu ý: Mã OTP này chỉ có hiệu lực trong vòng 5 phút.\n\n"
                + "Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc liên hệ với quản trị viên.\n\n"
                + "Trân trọng,\n"
                + "Ban quản trị FPT Golden.");
        
        mailSender.send(message);
    }
}