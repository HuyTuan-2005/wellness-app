import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/sleep_entry.dart';

class SleepController extends ChangeNotifier {
  static final SleepController _instance = SleepController._internal();
  factory SleepController() => _instance;

  List<SleepEntry> _history = [];

  SleepController._internal() {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    _history = await DatabaseHelper.instance.getAllSleepEntries();
    notifyListeners();
  }

  Future<void> reloadData() async {
    await _loadRecords();
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

    final newEntry = SleepEntry.create(
      bedTime: bedTime,
      wakeTime: wakeTime,
      hours: totalHours,
      createdAt: DateTime.now(),
    );

    _history.insert(0, newEntry);
    notifyListeners();

    DatabaseHelper.instance.insertSleepEntry(newEntry).then((id) {
      if (id > 0) {
        newEntry.id = id;
        DataSyncService.syncLocalToCloud();
      }
    });

    return SleepSessionResult.success;
  }

  Future<void> removeEntry(int index) async {
    if (index < 0 || index >= _history.length) return;
    final entry = _history[index];

    if (entry.id != null) {
      await DatabaseHelper.instance.deleteSleepEntry(entry.id!);
      DataSyncService.syncLocalToCloud();
    }
    
    _history.removeAt(index);
    notifyListeners();
  }
}

enum SleepSessionResult { success, invalidTimeRange }
