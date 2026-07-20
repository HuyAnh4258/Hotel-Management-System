package com.hotel.hms.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * Kích hoạt xử lý bất đồng bộ (@Async) cho toàn ứng dụng.
 * Dùng cho AuditLogService.logAsync() và các tác vụ nền khác.
 */
@Configuration
@EnableAsync
public class AsyncConfig {
}
