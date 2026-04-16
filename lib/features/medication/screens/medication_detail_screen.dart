import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/constants/enums.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final ReminderStatus status;

  const MedicationDetailScreen({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chi tiết thuốc",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF009688)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon và Tên thuốc
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication,
                      size: 48,
                      color: Color(0xFF009688),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(status),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Thông tin chi tiết
            _buildInfoTile(Icons.hourglass_empty, "Liều lượng", dosage),
            _buildInfoTile(Icons.access_time, "Giờ uống", time),
            _buildInfoTile(
              Icons.calendar_today,
              "Tần suất",
              "Hàng ngày",
            ), // Dựa trên Use Case 7.4 [cite: 47]
            _buildInfoTile(
              Icons.info_outline,
              "Ghi chú",
              "Uống sau khi ăn no 30 phút",
            ),

            const SizedBox(height: 40),

            // Nút hành động
            if (status != ReminderStatus.completed)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Đánh dấu đã uống",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReminderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status == ReminderStatus.completed
            ? Colors.grey[200]
            : const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == ReminderStatus.completed ? "Đã hoàn thành" : "Sắp tới",
        style: TextStyle(
          color: status == ReminderStatus.completed
              ? Colors.grey[700]
              : const Color(0xFF009688),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
