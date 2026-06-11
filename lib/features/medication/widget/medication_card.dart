import 'package:flutter/material.dart';

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
    Color iconBgColor;
    Color iconColor;
    Color textColor = const Color(0xFF1E293B);

    // LOGIC 9: ĐỔI MÀU THEO TRẠNG THÁI (BỎ LỠ LIỀU)
    if (status == "completed") {
      iconBgColor = Colors.grey[100]!;
      iconColor = Colors.grey;
      textColor = Colors.grey;
    } else if (status == "overdue") {
      iconBgColor = const Color(0xFFFFEBEE); // Đỏ nhạt
      iconColor = const Color(0xFFE53935); // Đỏ đậm
    } else {
      iconBgColor = primaryTeal.withValues(alpha: 0.1);
      iconColor = primaryTeal;
    }

    double progress = totalQuantity > 0 ? (takenQuantity / totalQuantity) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: status == "overdue"
            ? Border.all(color: const Color(0xFFFFEBEE), width: 2)
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medication, color: iconColor, size: 28),
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
                        fontSize: 18,
                        color: textColor,
                        decoration: status == "completed"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dosage,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == "overdue"
                            ? const Color(0xFFFFEBEE)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: status == "overdue"
                                ? const Color(0xFFE53935)
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status == "overdue" ? "Đã lỡ $time" : time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: status == "overdue"
                                  ? const Color(0xFFE53935)
                                  : Colors.grey[700],
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
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),

          // LOGIC 7: CẢNH BÁO SẮP HẾT THUỐC
          if (isWarning)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    warningMsg,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Row Progress & Nút bấm
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
                        color: status == 'completed' ? Colors.green : iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          status == 'completed' ? Colors.green : iconColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              status == "completed"
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 36,
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
                        child: const Text(
                          "Uống",
                          style: TextStyle(
                            color: Colors.white,
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
