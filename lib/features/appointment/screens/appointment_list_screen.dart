import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/appointment/models/appointment.dart';
import 'package:wellness_app/features/appointment/widgets/appointment_card.dart';
import 'appointment_detail_screen.dart';
import 'add_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // Hàm tải dữ liệu lịch hẹn từ Database
  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllAppointments();
    setState(() {
      _appointments = data;
      _isLoading = false;
    });
  }

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009688)),
            )
          : _appointments.isEmpty
          ? const Center(child: Text("Bạn chưa có lịch hẹn nào."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appt = _appointments[index];

                // Tách chuỗi dateTime thành Date và Time để hiển thị lên Card
                // Giả sử dateTime lưu dạng "20/04/2026 22:08" hoặc ISO8601
                String displayDate = appt.dateTime.split(
                  ' ',
                )[0]; // Cắt lấy phần ngày
                String displayTime = appt.dateTime.contains(' ')
                    ? appt.dateTime.split(' ')[1]
                    : appt.dateTime; // Cắt lấy giờ

                return GestureDetector(
                  onTap: () => _navigateToDetail(
                    context,
                    appt,
                    displayDate,
                    displayTime,
                  ),
                  child: AppointmentCard(
                    doctorName: appt.doctorName,
                    location: appt.location,
                    date: displayDate,
                    time: displayTime,
                    status: appt.status,
                    onViewDetails: () => _navigateToDetail(
                      context,
                      appt,
                      displayDate,
                      displayTime,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
          // Tải lại danh sách sau khi thêm mới thành công
          _loadAppointments();
        },
        backgroundColor: const Color(0xFF009688),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    AppointmentModel appt,
    String displayDate,
    String displayTime,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(
          doctorName: appt.doctorName,
          location: appt.location,
          date: displayDate,
          time: displayTime,
          status: appt.status,
        ),
      ),
    );
  }
}

