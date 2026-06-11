import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

/// Widget hiển thị thông báo hệ thống trên giao diện Người dùng (User).
class UserNotificationItem extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String category;

  const UserNotificationItem({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    this.category = 'general',
  });

  /// Xác định icon và màu dựa trên phân loại
  ({IconData icon, Color color}) get _categoryStyle {
    switch (category) {
      case 'maintenance':
        return (icon: Icons.build_circle_rounded, color: AppColors.warning);
      case 'health':
        return (icon: Icons.favorite_rounded, color: AppColors.error);
      case 'update':
        return (icon: Icons.system_update_rounded, color: AppColors.success);
      case 'promo':
        return (icon: Icons.campaign_rounded, color: AppColors.primary);
      default:
        return (icon: Icons.notifications_rounded, color: AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _categoryStyle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon phân loại với background mềm mại
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.color, size: 24),
          ),
          const SizedBox(width: 16),

          // Nội dung thông báo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề & Ngày giờ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Nội dung chi tiết
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
