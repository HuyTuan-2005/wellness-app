import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medical/medication/controller/medication_controller.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final String status;
  final String frequency;
  final String notes;
  final int takenQuantity;
  final int totalQuantity;
  final int durationDays;

  const MedicationDetailScreen({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    required this.frequency,
    required this.notes,
    required this.takenQuantity,
    required this.totalQuantity,
    required this.durationDays,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalQuantity > 0 ? (takenQuantity / totalQuantity) : 0;
    int dosePerTime = MedicationController.parseDoseAmount(dosage);
    int calculatedDay = dosePerTime > 0 ? (takenQuantity / dosePerTime).floor() : 0;
    int currentDay = min(calculatedDay, durationDays);

    // Xác định màu sắc và text theo trạng thái
    String badgeText;
    Color statusColor;
    Color statusBgColor;
    String timelineTitle;

    if (status == "completed") {
      badgeText = "Đã uống hôm nay";
      statusColor = AppColors.success;
      statusBgColor = AppColors.success.withValues(alpha: 0.1);
      timelineTitle = "Đã uống ($time)";
    } else if (status == "overdue") {
      badgeText = "Bỏ lỡ liều";
      statusColor = AppColors.error;
      statusBgColor = AppColors.error.withValues(alpha: 0.08);
      timelineTitle = "Đã lỡ hẹn ($time)";
    } else {
      badgeText = "Đang điều trị";
      statusColor = AppColors.primary;
      statusBgColor = AppColors.primary.withValues(alpha: 0.1);
      timelineTitle = "Sắp tới ($time)";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Chi tiết thuốc",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header — Icon + Tên thuốc + Badge trạng thái
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication, size: 56, color: statusColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. Tiến độ liệu trình
            Text(
              "Tiến độ liệu trình",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Số lượng:",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$takenQuantity / $totalQuantity viên",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Thời gian:",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        (currentDay == durationDays && status == "completed") 
                            ? "Đã hoàn thành liệu trình" 
                            : "Ngày $currentDay / $durationDays ngày",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        status == 'completed'
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Thông tin đơn thuốc
            Text(
              "Thông tin đơn thuốc",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.scale_outlined, "Liều lượng", dosage),
                  Divider(height: 32, color: AppColors.border),
                  _buildInfoRow(Icons.schedule, "Giờ uống", time),
                  Divider(height: 32, color: AppColors.border),
                  _buildInfoRow(
                    Icons.calendar_month_outlined,
                    "Tần suất",
                    frequency,
                  ),
                  Divider(height: 32, color: AppColors.border),
                  _buildInfoRow(Icons.info_outline, "Ghi chú", notes),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Lịch trình hôm nay
            Text(
              "Lịch trình hôm nay",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(time, timelineTitle, statusColor, statusBgColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String time,
    String title,
    Color statusColor,
    Color statusBgColor,
  ) {
    return Row(
      children: [
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(16),
              // Viền nhẹ cho trạng thái upcoming
              border: statusColor == AppColors.primary
                  ? Border.all(color: AppColors.border)
                  : null,
            ),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ),
      ],
    );
  }
}
