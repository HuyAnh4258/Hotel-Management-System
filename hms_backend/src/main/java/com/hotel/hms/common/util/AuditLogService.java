package com.hotel.hms.common.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * Ghi log hệ thống vào bảng AuditLog bất đồng bộ.
 * Được gọi sau khi lưu entity thành công từ các Service nghiệp vụ.
 */
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final JdbcTemplate jdbcTemplate;
    private final IdGenerator idGenerator;
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    /**
     * Ghi log bất đồng bộ — không block luồng nghiệp vụ chính.
     *
     * @param actionType Loại hành động: "CREATE", "UPDATE", "DELETE"
     * @param entity     Đối tượng entity đã được lưu (sẽ serialize thành JSON)
     */
    @Async
    public void logAsync(String actionType, Object entity) {
        try {
            String logId = idGenerator.generateTransactionalId("LOG");
            String newValues = objectMapper.writeValueAsString(entity);
            String tableName = entity.getClass().getSimpleName();

            jdbcTemplate.update(
                    "INSERT INTO AuditLog (LogId, UserId, ActionType, TableName, NewValues, Timestamp) VALUES (?, ?, ?, ?, ?, ?)",
                    logId,
                    "SYSTEM",
                    actionType,
                    tableName,
                    newValues,
                    LocalDateTime.now()
            );
        } catch (Exception ignored) {
            // Log lỗi nhưng không ảnh hưởng luồng chính
        }
    }
}
