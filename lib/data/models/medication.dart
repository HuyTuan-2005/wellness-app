import 'package:wellness_app/core/theme/constants/enums.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;
  ReminderStatus status;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.status =
        ReminderStatus.upcoming, // Mặc định khi mới thêm thuốc là "Sắp đến"
  });
}

// Dữ liệu giả để test UI
List<Medication> mockMedications = [
  Medication(
    id: '1',
    name: 'Paracetamol 500mg',
    dosage: '1 viên',
    time: '08:00 AM',
    status: ReminderStatus.upcoming,
  ),
  Medication(
    id: '2',
    name: 'Vitamin C',
    dosage: '2 viên',
    time: '14:00 PM',
    status: ReminderStatus.upcoming,
  ),
];
