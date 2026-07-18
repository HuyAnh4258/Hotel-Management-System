package com.hotel.hms.modules.authentication.repository;

import com.hotel.hms.modules.authentication.entity.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRole.UserRoleId> {

    List<UserRole> findByUser_UserId(String userId);
}
