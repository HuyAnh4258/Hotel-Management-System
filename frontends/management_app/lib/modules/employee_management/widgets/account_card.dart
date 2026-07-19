import 'package:flutter/material.dart';

import '../viewmodel/account_viewmodel.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onDeactivate,
    required this.onActivate,
  });

  final AccountModel account;
  final VoidCallback onTap;
  final VoidCallback? onDeactivate;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = account.isActive;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isActive ? Colors.grey.shade200 : Colors.red.shade100,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isActive
                      ? scheme.primary.withValues(alpha: 0.12)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: isActive ? scheme.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.fullName.isEmpty
                          ? account.username
                          : account.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${account.username}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _RoleBadge(roleName: account.roleName),
                        const SizedBox(width: 8),
                        _StatusBadge(isActive: isActive),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (isActive && onDeactivate != null)
                IconButton(
                  onPressed: onDeactivate,
                  icon: const Icon(Icons.block_rounded),
                  color: Colors.red.shade400,
                  tooltip: 'Vô hiệu hóa',
                ),
              if (!isActive && onActivate != null)
                IconButton(
                  onPressed: onActivate,
                  icon: const Icon(Icons.settings_backup_restore_rounded),
                  color: Colors.green.shade600,
                  tooltip: 'Khôi phục tài khoản',
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.roleName});

  final String roleName;

  Color get _color {
    switch (roleName.toUpperCase()) {
      case 'RECEPTIONIST':
        return const Color(0xFF1E88E5);
      case 'SERVICE_STAFF':
        return const Color(0xFFFF8F00);
      case 'HOUSEKEEPER':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (roleName.toUpperCase()) {
      case 'RECEPTIONIST':
        return 'Lễ tân';
      case 'SERVICE_STAFF':
        return 'Phục vụ';
      case 'HOUSEKEEPER':
        return 'Buồng phòng';
      default:
        return roleName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
