import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_theme.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      debugShowCheckedModeBanner: false,

      // darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,

      home: const AuthWrapper(),
    );
  }
}
