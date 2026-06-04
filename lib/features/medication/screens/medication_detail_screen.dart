import 'package:flutter/material.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final String status;
  final String frequency;
  final String notes;
  final int takenQuantity;
  final int totalQuantity;

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
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalQuantity > 0 ? (takenQuantity / totalQuantity) : 0;
    Color primaryTeal = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền xám nhạt
      appBar: AppBar(
        title: const Text(
          "Chi tiết thuốc",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF009688)),
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
            // 1. HEADER LỚN NHƯ THIẾT KẾ CỦA BẠN
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication, size: 56, color: primaryTeal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Đang điều trị",
                      style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. THẺ TIẾN ĐỘ ĐIỀU TRỊ
            const Text(
              "Tiến độ liệu trình",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(progress * 100).toInt()}% Hoàn thành",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "$takenQuantity / $totalQuantity viên",
                        style: TextStyle(
                          color: primaryTeal,
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
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. THÔNG TIN CHI TIẾT
            const Text(
              "Thông tin đơn thuốc",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.scale_outlined, "Liều lượng", dosage),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(Icons.schedule, "Giờ uống", time),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(
                    Icons.calendar_month_outlined,
                    "Tần suất",
                    frequency,
                  ),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(Icons.info_outline, "Ghi chú", notes),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. LỊCH SỬ UỐNG THUỐC (UI MOCKUP)
            const Text(
              "Lịch sử hôm nay",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              time,
              status == "completed" ? "Đã uống" : "Sắp tới",
              isCompleted: status == "completed",
            ),
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String time,
    String title, {
    required bool isCompleted,
  }) {
    Color color = isCompleted ? Colors.green : Colors.grey[400]!;
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 16),
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isCompleted ? null : Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.green : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
