import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/water_entry.dart';

class WaterController extends ChangeNotifier {
  // Singleton pattern
  static final WaterController _instance = WaterController._internal();
  factory WaterController() => _instance;

  WaterController._internal();

  int _currentMl = 0;
  final List<WaterEntry> _history = [];

  int get currentMl => _currentMl;
  int get goalMl => UserProfile.dailyWaterGoal;
  List<WaterEntry> get history => List.unmodifiable(_history);

  double get progress => (_currentMl / goalMl).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  int get glassesLeft => ((goalMl - _currentMl) / 250).ceil().clamp(0, 999);

  bool addWater(int ml) {
    if (ml <= 0) return false;
    final wasBelowGoal = _currentMl < goalMl;
    _currentMl += ml;
    _history.insert(0, WaterEntry(ml: ml, time: TimeOfDay.now()));
    notifyListeners();
    return wasBelowGoal && _currentMl >= goalMl;
  }

  bool updateGoal(int goalMl) {
    if (goalMl < 500) return false;
    UserProfile.dailyWaterGoal = goalMl;

    // Cập nhật lên Firestore nếu user đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'dailyWaterGoal': goalMl,
      }).catchError((e) => debugPrint('Lỗi cập nhật mục tiêu nước lên Firestore: $e'));
    }

    notifyListeners();
    return true;
  }

  void removeEntry(int index) {
    if (index < 0 || index >= _history.length) return;
    _currentMl -= _history[index].ml;
    if (_currentMl < 0) _currentMl = 0;
    _history.removeAt(index);
    notifyListeners();
  }
}
