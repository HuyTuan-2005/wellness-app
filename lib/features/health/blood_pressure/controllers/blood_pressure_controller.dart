import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/blood_pressure_entry.dart';

class BloodPressureController extends ChangeNotifier {
  // Singleton pattern
  static final BloodPressureController _instance = BloodPressureController._internal();
  factory BloodPressureController() => _instance;

  StreamSubscription? _subscription;
  final List<BloodPressureEntry> _history = [];

  BloodPressureController._internal() {
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
        .collection('blood_pressure_logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _history.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final entry = BloodPressureEntry.fromMap(doc.id, data);
        _history.add(entry);
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to blood pressure logs: $e");
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _history.clear();
    notifyListeners();
  }

  int get targetSystolic => UserProfile.targetSystolic;
  int get targetDiastolic => UserProfile.targetDiastolic;
  List<BloodPressureEntry> get history => List.unmodifiable(_history);

  BloodPressureEntry? get latest => _history.isEmpty ? null : _history.first;

  double get pressureScore {
    if (latest == null) return 0;
    final sysScore = (targetSystolic / latest!.systolic).clamp(0.0, 1.0);
    final diaScore = (targetDiastolic / latest!.diastolic).clamp(0.0, 1.0);
    return ((sysScore + diaScore) / 2).clamp(0.0, 1.0);
  }

  String get statusText {
    final entry = latest;
    if (entry == null) return 'Chưa có dữ liệu';
    return classify(entry);
  }

  String classify(BloodPressureEntry entry) {
    if (entry.systolic < 90 || entry.diastolic < 60) {
      return 'Thấp';
    }
    if (entry.systolic >= 140 || entry.diastolic >= 90) {
      return 'Cao';
    }
    return 'Bình thường';
  }

  Color statusColorFor(BloodPressureEntry entry) {
    final status = classify(entry);
    if (status == 'Bình thường') return Colors.green;
    if (status == 'Thấp') return Colors.orange;
    return Colors.red;
  }

  String? dangerMessageFor(BloodPressureEntry entry) {
    final isDangerouslyHigh = entry.systolic >= 180 || entry.diastolic >= 120;
    final isDangerouslyLow = entry.systolic < 80 || entry.diastolic < 50;
    if (isDangerouslyHigh || isDangerouslyLow) {
      return 'Chỉ số ở mức nguy hiểm. Bạn nên nghỉ ngơi và liên hệ bác sĩ.';
    }
    return null;
  }

  void addReading({required int systolic, required int diastolic, required String trigger}) {
    final newEntry = BloodPressureEntry(
      systolic: systolic,
      diastolic: diastolic,
      trigger: trigger,
      time: TimeOfDay.now(),
      createdAt: DateTime.now(),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _saveReadingToFirestore(user.uid, newEntry);
    } else {
      _history.insert(0, newEntry);
      notifyListeners();
    }
  }

  Future<void> _saveReadingToFirestore(String uid, BloodPressureEntry entry) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('blood_pressure_logs')
          .add(entry.toMap());
    } catch (e) {
      debugPrint("Error saving BP reading to Firestore: $e");
    }
  }

  Future<void> updateTarget({required int systolic, required int diastolic}) async {
    if (systolic < 90 || diastolic < 60) return;
    UserProfile.targetSystolic = systolic;
    UserProfile.targetDiastolic = diastolic;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'targetSystolic': systolic,
          'targetDiastolic': diastolic,
        });
      } catch (e) {
        debugPrint('Lỗi cập nhật mục tiêu huyết áp lên Firestore: $e');
      }
    }

    notifyListeners();
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
            .collection('blood_pressure_logs')
            .doc(entry.id)
            .delete();
      } catch (e) {
        debugPrint("Error deleting BP log: $e");
      }
    } else {
      _history.removeAt(index);
      notifyListeners();
    }
  }
}
