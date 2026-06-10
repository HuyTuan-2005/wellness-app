import 'package:flutter/material.dart';
import 'package:wellness_app/app.dart';
import 'package:wellness_app/service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // KHỞI TẠO HỆ THỐNG THÔNG BÁO VÀ XIN QUYỀN
  await NotificationService().init();
  await NotificationService().requestPermissions();
  runApp(const WellnessApp());
}
