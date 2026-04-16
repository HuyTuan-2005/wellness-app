import 'package:wellness_app/core/theme/constants/enums.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String location;
  final String date;
  final String time;
  ReminderStatus status;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.location,
    required this.date,
    required this.time,
    this.status = ReminderStatus.upcoming,
  });
}

List<Appointment> mockAppointments = [
  Appointment(
    id: '1',
    doctorName: 'Dr. Nguyễn Văn A',
    location: 'Bệnh viện Đa khoa Quốc tế',
    date: '25/10/2026',
    time: '09:00 AM',
    status: ReminderStatus.upcoming,
  ),
  Appointment(
    id: '2',
    doctorName: 'Dr. Trần Thị B',
    location: 'Phòng khám Da liễu',
    date: '28/10/2026',
    time: '15:30 PM',
    status: ReminderStatus.completed,
  ),
];
