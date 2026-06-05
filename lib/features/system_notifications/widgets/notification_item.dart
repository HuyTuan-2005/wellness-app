import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

/// Widget hiển thị một thông báo hệ thống.
/// Gồm: icon phân loại, tiêu đề, nội dung tóm tắt, ngày giờ gửi.
class NotificationItem extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String category;

  const NotificationItem({
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: style.color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: icon + tiêu đề + ngày
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon phân loại
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(style.icon, color: style.color, size: 18),
                  ),
                  const SizedBox(width: 12),

                  // Tiêu đề
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Ngày giờ
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Nội dung tóm tắt
              Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Trạng thái đã gửi
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã gửi đến tất cả người dùng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
