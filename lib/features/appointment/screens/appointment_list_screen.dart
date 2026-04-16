import 'package:flutter/material.dart';
import 'package:wellness_app/data/models/appointment.dart';
import 'package:wellness_app/features/appointment/screens/appointment_detail_screen.dart';
import 'package:wellness_app/features/appointment/widgets/appointment_card.dart';
import 'add_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Lịch hẹn bác sĩ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockAppointments.length,
        itemBuilder: (context, index) {
          final appt = mockAppointments[index];

          return GestureDetector(
            onTap: () {
              // Bấm vào vùng trống của thẻ cũng chuyển sang chi tiết
              _navigateToDetail(context, appt);
            },
            child: AppointmentCard(
              doctorName: appt.doctorName,
              location: appt.location,
              date: appt.date,
              time: appt.time,
              status: appt.status,
              onViewDetails: () {
                // Bấm vào chữ "Xem chi tiết" cũng chuyển trang
                _navigateToDetail(context, appt);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF246BFD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Hàm chuyển trang được tách ra để code gọn gàng, có thể dùng lại ở nhiều chỗ
  void _navigateToDetail(BuildContext context, Appointment appt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(
          doctorName: appt.doctorName,
          location: appt.location,
          date: appt.date,
          time: appt.time,
          status: appt.status,
        ),
      ),
    );
  }
}
