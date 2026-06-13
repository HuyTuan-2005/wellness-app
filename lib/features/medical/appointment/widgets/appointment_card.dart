import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String location;
  final String date;
  final String time;
  final String status; // "upcoming", "completed", "overdue"
  final VoidCallback onViewDetails;
  final VoidCallback onNavigate;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.onViewDetails,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == "completed";
    final bool isOverdue = status == "overdue";

    // Đổi màu icon, nền, text theo trạng thái
    Color iconBgColor;
    Color iconColor;
    Color cardTextColor = AppColors.textDark;
    IconData cardIcon = Icons.medical_services;

    if (isCompleted) {
      iconBgColor = AppColors.success.withValues(alpha: 0.12);
      iconColor = AppColors.success;
      cardTextColor = AppColors.textSecondary;
      cardIcon = Icons.check_circle_rounded;
    } else if (isOverdue) {
      iconBgColor = AppColors.error.withValues(alpha: 0.08);
      iconColor = AppColors.error;
    } else {
      iconBgColor = AppColors.primary.withValues(alpha: 0.08);
      iconColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: isOverdue
              ? Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 2)
              : isCompleted
                  ? Border.all(
                      color: AppColors.success.withValues(alpha: 0.15), width: 1.5)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(cardIcon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: cardTextColor,
                          ),
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "Đã khám",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                            color: isOverdue ? AppColors.error : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.navigation, color: AppColors.primary),
              onPressed: onNavigate,
            ),
          ],
        ),
      ),
    );
  }
}
