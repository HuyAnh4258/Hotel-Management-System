package com.hotel.hms.repository;

import com.hotel.hms.entity.UserAccount;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserAccountRepository extends JpaRepository<UserAccount, String> {
    Optional<UserAccount> findByUsername(String username);

    Optional<UserAccount> findByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    /**
     * Find all users who have at least one of the specified roles.
     * Used to list employee accounts only (exclude OWNER, GUEST).
     */
    @Query("""
            SELECT DISTINCT u FROM UserAccount u
            JOIN u.roles r
            WHERE r.roleName IN :roleNames
            ORDER BY u.createdAt DESC
            """)
    List<UserAccount> findByRoleNames(@Param("roleNames") List<String> roleNames);

    /**
     * Search users by name, username, or phone within specific roles.
     */
    @Query("""
            SELECT DISTINCT u FROM UserAccount u
            JOIN u.roles r
            LEFT JOIN u.employeeProfile ep
            WHERE r.roleName IN :roleNames
              AND (
                LOWER(u.username) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR LOWER(ep.fullName) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR ep.phone LIKE CONCAT('%', :keyword, '%')
              )
            ORDER BY u.createdAt DESC
            """)
    List<UserAccount> searchByKeyword(
            @Param("keyword") String keyword,
            @Param("roleNames") List<String> roleNames
    );
}
