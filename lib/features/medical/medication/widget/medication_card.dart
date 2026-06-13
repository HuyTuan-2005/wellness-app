import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final String status;
  final int takenQuantity;
  final int totalQuantity;
  final bool isWarning;
  final String warningMsg;
  final VoidCallback onMarkAsTaken;
  final VoidCallback onDelete;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status, // "upcoming", "completed", "overdue"
    required this.takenQuantity,
    required this.totalQuantity,
    this.isWarning = false,
    this.warningMsg = "",
    required this.onMarkAsTaken,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF009688);
    final bool isCompleted = status == "completed";
    final bool isOverdue = status == "overdue";

    // Đổi màu icon, nền, text theo trạng thái: upcoming → primary, overdue → error, completed → success
    Color iconBgColor;
    Color iconColor;
    Color cardTextColor = AppColors.textDark;
    IconData cardIcon = Icons.medication;

    if (isCompleted) {
      iconBgColor = AppColors.success.withOpacity(0.12);
      iconColor = AppColors.success;
      cardTextColor = AppColors.textSecondary;
      cardIcon = Icons.check_circle_rounded;
    } else if (isOverdue) {
      iconBgColor = AppColors.error.withOpacity(0.08);
      iconColor = AppColors.error;
    } else {
      iconBgColor = primaryTeal.withValues(alpha: 0.1);
      iconColor = primaryTeal;
    }

    double progress = totalQuantity > 0 ? (takenQuantity / totalQuantity) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Card đã uống có nền xanh lá rất nhạt để phân biệt trực quan
        color: isCompleted
            ? AppColors.success.withOpacity(0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: isOverdue
            ? Border.all(color: AppColors.error.withOpacity(0.2), width: 2)
            : isCompleted
            ? Border.all(color: AppColors.success.withOpacity(0.15), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon trạng thái: check khi đã uống, pill khi chưa
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
                    // Tên thuốc + badge "Đã uống" thay cho lineThrough
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
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
                              color: AppColors.success.withOpacity(0.12),
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
                                  "Đã uống",
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
                    const SizedBox(height: 4),
                    Text(
                      dosage,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badge hiển thị giờ uống, đổi màu theo trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppColors.error.withOpacity(0.08)
                            : isCompleted
                            ? AppColors.success.withOpacity(0.08)
                            : AppColors.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_outline
                                : Icons.schedule,
                            size: 14,
                            color: isOverdue
                                ? AppColors.error
                                : isCompleted
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue ? "Đã lỡ $time" : time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? AppColors.error
                                  : isCompleted
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),

          // Cảnh báo sắp hết thuốc
          if (isWarning)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    warningMsg,
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Thanh tiến độ & nút uống thuốc
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tiến độ: $takenQuantity/$totalQuantity",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.success : iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : iconColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Icon hoàn thành (có nền tròn) hoặc nút "Uống"
              isCompleted
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 32,
                      ),
                    )
                  : InkWell(
                      onTap: onMarkAsTaken,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Uống",
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
