import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

/// Widget thẻ người dùng – hiển thị avatar, tên, email và badge trạng thái.
class UserCard extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String email;
  final bool isActive;
  final String role;

  const UserCard({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.email,
    required this.isActive,
    this.role = 'Người dùng',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 12),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Role tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Badge trạng thái
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl!),
        );
      }
      return CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(avatarUrl!),
      );
    }

    // Avatar mặc định: chữ cái đầu
    final initial = name.isNotEmpty ? name.trim().split(' ').last[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final Color badgeColor = isActive ? AppColors.success : AppColors.error;
    final String statusText = isActive ? 'Hoạt động' : 'Bị khóa';
    final IconData statusIcon = isActive ? Icons.check_circle_rounded : Icons.block_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
