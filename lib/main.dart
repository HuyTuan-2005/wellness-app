import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellness_app/app.dart';
import 'package:wellness_app/firebase_options.dart';
import 'package:wellness_app/service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (bắt buộc cho Auth, Firestore, FCM)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo Notification Service (timezone + plugin)
  await NotificationService().init();

  // Yêu cầu quyền thông báo (Android 13+)
  await NotificationService().requestPermissions();

  runApp(const WellnessApp());
}
