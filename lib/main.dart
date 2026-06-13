import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wellness_app/app.dart';
import 'package:wellness_app/firebase_options.dart';
import 'package:wellness_app/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();

  // Khởi tạo Notification Service (timezone + plugin)
  await NotificationService().init();

  // Yêu cầu quyền thông báo (Android 13+)
  await NotificationService().requestPermissions();

  runApp(const WellnessApp());
}
