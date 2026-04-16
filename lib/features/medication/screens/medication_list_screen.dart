import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/constants/enums.dart';
import 'package:wellness_app/data/models/medication.dart';
import 'package:wellness_app/features/medication/screens/add_medication_screen.dart';
import 'package:wellness_app/features/medication/widget/medication_card.dart';

import 'medication_detail_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt chuẩn Asklepios
      appBar: AppBar(
        title: const Text(
          'Lịch uống thuốc',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockMedications.length,
        itemBuilder: (context, index) {
          final med = mockMedications[index];

          // Bọc GestureDetector để người dùng bấm vào thẻ là sang màn hình chi tiết
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationDetailScreen(
                    name: med.name,
                    dosage: med.dosage,
                    time: med.time,
                    status: med.status,
                  ),
                ),
              );
            },
            child: MedicationCard(
              name: med.name,
              dosage: med.dosage,
              time: med.time,
              status: med.status,
              onMarkAsTaken: () {
                if (med.status == ReminderStatus.completed) return;

                setState(() {
                  mockMedications[index].status = ReminderStatus.completed;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đánh dấu "${med.name}" là đã uống!'),
                    backgroundColor: const Color(0xFF009688),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
              builder: (context) => const AddMedicationScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF009688),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
