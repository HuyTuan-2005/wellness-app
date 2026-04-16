import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_theme.dart';
import 'package:wellness_app/features/BMI/screens/BMI_screen.dart';
import 'package:wellness_app/features/admin_dashboard/screens/dashboard_screen.dart';
import 'package:wellness_app/features/appointment/screens/appointment_list_screen.dart';
import 'package:wellness_app/features/home/screens/home_screen.dart';
import 'package:wellness_app/features/medication/screens/medication_list_screen.dart';
import 'package:wellness_app/features/nutrition/screens/nutrition_tracking_screen.dart';
import 'package:wellness_app/features/profile/screens/profile_screen.dart';
import 'package:wellness_app/features/register_login/screens/register_screen.dart';

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
      home: const RegisterScreen(),
    );
  }
}
