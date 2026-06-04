import 'package:flutter/material.dart';
import 'package:wellness_app/app.dart';

void main() {
  debugPrint("==== BƯỚC 1: KHỞI TẠO FLUTTER ====");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("==== BƯỚC 2: CHẠY RUN APP ====");
  runApp(const WellnessApp());
}
