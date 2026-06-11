import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_theme.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';
import 'package:wellness_app/features/medication/screens/medication_list_screen.dart';
import 'package:wellness_app/features/appointment/screens/appointment_list_screen.dart';
import 'package:wellness_app/features/medical/screens/medical_schedule_screen.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      debugShowCheckedModeBanner: false,

      // darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,

      //home: const AuthWrapper(),
      //home: const MedicationListScreen(),
      //home: const AppointmentListScreen(),
      home: const MedicalScheduleScreen(),
    );
  }
}
