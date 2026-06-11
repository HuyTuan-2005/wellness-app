import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/medication/screens/medication_list_screen.dart';
import 'package:wellness_app/features/appointment/screens/appointment_list_screen.dart';

class MedicalScheduleScreen extends StatelessWidget {
  const MedicalScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Y tế',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.medication), text: 'Lịch uống thuốc'),
              Tab(icon: Icon(Icons.medical_services), text: 'Lịch khám'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Màn hình Thuốc
            MedicationListScreen(),
            // Tab 2: Màn hình Lịch khám
            AppointmentListScreen(),
          ],
        ),
      ),
    );
  }
}
