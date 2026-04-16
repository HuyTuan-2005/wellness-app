import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_theme.dart';
import 'package:wellness_app/features/admin_dashboard/screens/dashboard_screen.dart';
import 'package:wellness_app/features/appointment/screens/appointment_list_screen.dart';
import 'package:wellness_app/features/medication/screens/medication_list_screen.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Sức khỏe',
      debugShowCheckedModeBanner: false,

      // darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,

      // home: const DashboardScreen(),
      home: const MedicationListScreen(),
      // home: const AppointmentListScreen(),
    );
  }
}
