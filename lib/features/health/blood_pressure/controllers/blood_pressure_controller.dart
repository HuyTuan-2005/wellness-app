import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/blood_pressure_entry.dart';

class BloodPressureController extends ChangeNotifier {
  static final BloodPressureController _instance = BloodPressureController._internal();
  factory BloodPressureController() => _instance;

  List<BloodPressureEntry> _history = [];

  BloodPressureController._internal() {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    _history = await DatabaseHelper.instance.getAllBloodPressureEntries();
    notifyListeners();
  }

  Future<void> reloadData() async {
    await _loadRecords();
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
    final newEntry = BloodPressureEntry.create(
      systolic: systolic,
      diastolic: diastolic,
      trigger: trigger,
      time: TimeOfDay.now(),
      createdAt: DateTime.now(),
    );

    _history.insert(0, newEntry);
    notifyListeners();

    DatabaseHelper.instance.insertBloodPressureEntry(newEntry).then((id) {
      if (id > 0) {
        newEntry.id = id;
        DataSyncService.syncLocalToCloud();
      }
    });
  }

  Future<void> updateTarget({required int systolic, required int diastolic}) async {
    if (systolic < 90 || diastolic < 60) return;
    UserProfile.targetSystolic = systolic;
    UserProfile.targetDiastolic = diastolic;
    notifyListeners();
  }

  Future<void> removeEntry(int index) async {
    if (index < 0 || index >= _history.length) return;
    final entry = _history[index];

    if (entry.id != null) {
      await DatabaseHelper.instance.deleteBloodPressureEntry(entry.id!);
      DataSyncService.syncLocalToCloud();
    }
    
    _history.removeAt(index);
    notifyListeners();
  }
}
