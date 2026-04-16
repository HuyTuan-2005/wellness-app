import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/constants/enums.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String doctorName;
  final String location;
  final String date;
  final String time;
  final ReminderStatus status;

  const AppointmentDetailScreen({
    super.key,
    required this.doctorName,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Chi tiết lịch hẹn",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card chính chứa thông tin bác sĩ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFE0F2F1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF246BFD),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Chuyên khoa nội",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.calendar_today, "Ngày khám", date),
                  _buildDetailRow(Icons.access_time, "Giờ khám", time),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    "Địa điểm",
                    location,
                  ),
                  _buildDetailRow(
                    Icons.notifications_active_outlined,
                    "Nhắc trước",
                    "1 giờ",
                  ), // Theo Use Case 7.5 [cite: 48]
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ghi chú
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ghi chú",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Mang theo kết quả xét nghiệm máu lần trước và nhịn ăn sáng.",
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nút chỉ đường (Giả lập)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.directions),
              label: const Text("Chỉ đường đến phòng khám"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF246BFD),
                side: const BorderSide(color: Color(0xFF246BFD)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF246BFD)),
          const SizedBox(width: 12),
          Text("$label: ", style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
