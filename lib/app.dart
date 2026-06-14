import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_theme.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';
import 'package:wellness_app/features/intro/screens/intro_screen.dart';

class WellnessApp extends StatelessWidget {
  final bool isFirstTime;

  const WellnessApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness App',
      debugShowCheckedModeBanner: false,

      // darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,

      home: isFirstTime ? const IntroScreen() : const AuthWrapper(),
    );
  }
}
