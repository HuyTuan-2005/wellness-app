import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/water_entry.dart';

class WaterController extends ChangeNotifier {
  // Singleton pattern
  static final WaterController _instance = WaterController._internal();
  factory WaterController() => _instance;

  StreamSubscription? _subscription;
  String? _userId;
  String? _dateStr;

  int _currentMl = 0;
  final List<WaterEntry> _history = [];

  WaterController._internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _subscribeToToday();
      } else {
        _unsubscribe();
        _userId = null;
      }
    });
  }

  String _getTodayDateStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _subscribeToToday() {
    if (_userId == null) return;
    final today = _getTodayDateStr();
    _dateStr = today;
    
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('water_logs')
        .doc(today)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        _currentMl = data['currentMl'] ?? 0;
        final historyData = data['history'] as List<dynamic>? ?? [];
        _history.clear();
        for (var h in historyData) {
          _history.add(WaterEntry.fromMap(h));
        }
      } else {
        _currentMl = 0;
        _history.clear();
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to today's water logs: $e");
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _currentMl = 0;
    _history.clear();
    _dateStr = null;
    notifyListeners();
  }

  int get currentMl {
    if (_userId != null && _dateStr != _getTodayDateStr()) {
      _subscribeToToday();
    }
    return _currentMl;
  }

  int get goalMl => UserProfile.dailyWaterGoal;
  List<WaterEntry> get history {
    if (_userId != null && _dateStr != _getTodayDateStr()) {
      _subscribeToToday();
    }
    return List.unmodifiable(_history);
  }

  double get progress => (currentMl / goalMl).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  int get glassesLeft => ((goalMl - currentMl) / 250).ceil().clamp(0, 999);

  bool addWater(int ml) {
    if (ml <= 0) return false;
    
    if (_userId != null && _dateStr != _getTodayDateStr()) {
      _subscribeToToday();
    }

    final wasBelowGoal = _currentMl < goalMl;
    _currentMl += ml;
    _history.insert(0, WaterEntry(ml: ml, time: TimeOfDay.now()));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('water_logs')
          .doc(_getTodayDateStr())
          .set({
        'currentMl': _currentMl,
        'history': _history.map((e) => e.toMap()).toList(),
      }).catchError((e) => debugPrint("Error updating water log to Firestore: $e"));
    } else {
      notifyListeners();
    }
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
    
    if (_userId != null && _dateStr != _getTodayDateStr()) {
      _subscribeToToday();
    }

    _currentMl -= _history[index].ml;
    if (_currentMl < 0) _currentMl = 0;
    _history.removeAt(index);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('water_logs')
          .doc(_getTodayDateStr())
          .set({
        'currentMl': _currentMl,
        'history': _history.map((e) => e.toMap()).toList(),
      }).catchError((e) => debugPrint("Error updating water log in Firestore: $e"));
    } else {
      notifyListeners();
    }
  }
}
