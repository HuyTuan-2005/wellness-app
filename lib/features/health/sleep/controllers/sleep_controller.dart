import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';

class SleepController extends ChangeNotifier {
  // Singleton pattern
  static final SleepController _instance = SleepController._internal();
  factory SleepController() => _instance;

  StreamSubscription? _subscription;
  final List<SleepEntry> _history = [];

  SleepController._internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _subscribe(user.uid);
      } else {
        _unsubscribe();
      }
    });
  }

  void _subscribe(String uid) {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sleep_logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _history.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final entry = SleepEntry.fromMap(doc.id, data);
              _history.add(entry);
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error listening to sleep logs: $e");
          },
        );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _history.clear();
    notifyListeners();
  }

  double get todayHours => _history.fold(0.0, (total, e) => total + e.hours);
  double get goalHours => UserProfile.sleepGoalHours;
  List<SleepEntry> get history => List.unmodifiable(_history);
  double get progress => (todayHours / goalHours).clamp(0.0, 1.0);
  SleepEntry? get latest => _history.isEmpty ? null : _history.first;

  String get latestQualityText {
    final entry = latest;
    if (entry == null) return 'Chưa có dữ liệu';
    if (entry.hours < 7) return 'Ngủ chưa đủ';
    if (entry.hours <= 9) return 'Giấc ngủ tốt';
    return 'Ngủ nhiều hơn khuyến nghị';
  }

  String get recommendationText => 'Khuyến nghị: 7 - 9 giờ/ngày';

  Future<void> updateGoal(double value) async {
    if (value <= 0) return;
    UserProfile.sleepGoalHours = value;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'sleepGoalHours': value});
      } catch (e) {
        debugPrint('Lỗi cập nhật mục tiêu ngủ lên Firestore: $e');
      }
    }

    notifyListeners();
  }

  SleepSessionResult addSleepSession({
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
  }) {
    final bedMinutes = bedTime.hour * 60 + bedTime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;

    if (wakeMinutes == bedMinutes) {
      return SleepSessionResult.invalidTimeRange;
    }

    int totalMinutes = wakeMinutes - bedMinutes;
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    final totalHours = totalMinutes / 60.0;

    final newEntry = SleepEntry(
      bedTime: bedTime,
      wakeTime: wakeTime,
      hours: totalHours,
      createdAt: DateTime.now(),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _saveSleepSessionToFirestore(user.uid, newEntry);
    } else {
      _history.insert(0, newEntry);
      notifyListeners();
    }

    return SleepSessionResult.success;
  }

  Future<void> _saveSleepSessionToFirestore(
    String uid,
    SleepEntry entry,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sleep_logs')
          .add(entry.toMap());
    } catch (e) {
      debugPrint("Error saving sleep session to Firestore: $e");
    }
  }

  Future<void> removeEntry(int index) async {
    if (index < 0 || index >= _history.length) return;
    final entry = _history[index];

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && entry.id != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sleep_logs')
            .doc(entry.id)
            .delete();
      } catch (e) {
        debugPrint("Error deleting sleep log: $e");
      }
    } else {
      _history.removeAt(index);
      notifyListeners();
    }
  }
}

enum SleepSessionResult { success, invalidTimeRange }

class SleepEntry {
  final String? id;
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final double hours;
  final DateTime createdAt;

  SleepEntry({
    this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.hours,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bedTime': {'hour': bedTime.hour, 'minute': bedTime.minute},
      'wakeTime': {'hour': wakeTime.hour, 'minute': wakeTime.minute},
      'hours': hours,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepEntry.fromMap(String id, Map<String, dynamic> map) {
    final bedTimeMap = map['bedTime'] as Map<dynamic, dynamic>;
    final wakeTimeMap = map['wakeTime'] as Map<dynamic, dynamic>;
    return SleepEntry(
      id: id,
      bedTime: TimeOfDay(
        hour: (bedTimeMap['hour'] as num).toInt(),
        minute: (bedTimeMap['minute'] as num).toInt(),
      ),
      wakeTime: TimeOfDay(
        hour: (wakeTimeMap['hour'] as num).toInt(),
        minute: (wakeTimeMap['minute'] as num).toInt(),
      ),
      hours: (map['hours'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
