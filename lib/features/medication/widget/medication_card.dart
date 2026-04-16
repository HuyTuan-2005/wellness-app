import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/constants/enums.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final ReminderStatus status;
  final VoidCallback onMarkAsTaken;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    required this.onMarkAsTaken,
  });

  @override
  Widget build(BuildContext context) {
    // Xử lý màu sắc theo trạng thái
    Color iconBgColor;
    Color iconColor;
    Color textColor = Colors.black;
    Widget trailingWidget;

    switch (status) {
      case ReminderStatus.completed:
        iconBgColor = Colors.grey[200]!;
        iconColor = Colors.grey;
        textColor = Colors.grey;
        trailingWidget = const Icon(Icons.check_circle, color: Colors.green);
        break;
      case ReminderStatus.overdue:
        iconBgColor = const Color(0xFFFFEBEE); // Đỏ nhạt
        iconColor = const Color(0xFFE53935); // Đỏ đậm
        trailingWidget = _buildActionButton("Đã uống", const Color(0xFFE53935));
        break;
      case ReminderStatus.upcoming:
      default:
        iconBgColor = const Color(0xFFE0F2F1); // Teal nhạt
        iconColor = const Color(0xFF246BFD); // Teal đậm
        trailingWidget = _buildActionButton("Đã uống", const Color(0xFF246BFD));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                    decoration: status == ReminderStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  dosage,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailingWidget,
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return InkWell(
      onTap: onMarkAsTaken,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
