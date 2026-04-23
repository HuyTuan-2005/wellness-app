import 'package:flutter/material.dart';

class SleepController extends ChangeNotifier {
  double _goalHours = 8;
  final List<SleepEntry> _history = [];

  double get todayHours => _history.fold(0.0, (sum, e) => sum + e.hours);
  double get goalHours => _goalHours;
  List<SleepEntry> get history => List.unmodifiable(_history);
  double get progress => (todayHours / _goalHours).clamp(0.0, 1.0);
  SleepEntry? get latest => _history.isEmpty ? null : _history.first;

  String get latestQualityText {
    final entry = latest;
    if (entry == null) return 'Chưa có dữ liệu';
    if (entry.hours < 7) return 'Ngủ chưa đủ';
    if (entry.hours <= 9) return 'Giấc ngủ tốt';
    return 'Ngủ nhiều hơn khuyến nghị';
  }

  String get recommendationText => 'Khuyến nghị: 7 - 9 giờ/ngày';

  void updateGoal(double value) {
    if (value < 4 || value > 12) return;
    _goalHours = value;
    notifyListeners();
  }

  SleepSessionResult addSleepSession({required TimeOfDay bedTime, required TimeOfDay wakeTime}) {
    final bedMinutes = bedTime.hour * 60 + bedTime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;

    // Theo use case: giờ thức phải sau giờ đi ngủ trong cùng một ngày.
    if (wakeMinutes <= bedMinutes) {
      return SleepSessionResult.invalidTimeRange;
    }

    final totalMinutes = wakeMinutes - bedMinutes;
    final totalHours = totalMinutes / 60.0;

    _history.insert(
      0,
      SleepEntry(
        bedTime: bedTime,
        wakeTime: wakeTime,
        hours: totalHours,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return SleepSessionResult.success;
  }

  void removeEntry(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    notifyListeners();
  }
}

enum SleepSessionResult { success, invalidTimeRange }

class SleepEntry {
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final double hours;
  final DateTime createdAt;

  SleepEntry({
    required this.bedTime,
    required this.wakeTime,
    required this.hours,
    required this.createdAt,
  });
}
