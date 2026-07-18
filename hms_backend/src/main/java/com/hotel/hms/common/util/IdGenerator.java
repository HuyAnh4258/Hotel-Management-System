package com.hotel.hms.common.util;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

@Component
public class IdGenerator {

    public String generateStaticId(String prefix, JpaRepository<?, String> repository) {
        long next = repository.count() + 1;
        return prefix + String.format("%04d", next);
    }
}