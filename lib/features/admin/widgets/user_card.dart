import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

/// Widget thẻ người dùng – hiển thị avatar, tên, email và badge trạng thái.
class UserCard extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String email;
  final bool isActive;
  final String? lockReason;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.email,
    required this.isActive,
    this.lockReason,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Badge trạng thái
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(),
                if (!isActive && lockReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lý do: $lockReason',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildAvatar() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl!),
        );
      }
      return CircleAvatar(radius: 20, backgroundImage: AssetImage(avatarUrl!));
    }

    // Avatar mặc định: chữ cái đầu
    final initial = name.isNotEmpty
        ? name.trim().split(' ').last[0].toUpperCase()
        : '?';
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
    final IconData statusIcon = isActive
        ? Icons.check_circle_rounded
        : Icons.block_rounded;

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
