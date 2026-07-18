package com.hotel.hms.common.util;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Component
public class IdGenerator {

    private static final DateTimeFormatter TS_FORMAT = DateTimeFormatter.ofPattern("yyMMddHHmmss");
    private final Map<String, AtomicLong> sequences = new ConcurrentHashMap<>();

    public String generateStaticId(String prefix, JpaRepository<?, String> repository) {
        AtomicLong seq = sequences.computeIfAbsent(prefix,
                k -> new AtomicLong(repository.count() + 1));
        return prefix + "-" + String.format("%08d", seq.getAndIncrement());
    }

    public String generateTransactionalId(String prefix) {
        String ts = LocalDateTime.now().format(TS_FORMAT);
        String hex = UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        return prefix + "-" + ts + "-" + hex;
    }
}
