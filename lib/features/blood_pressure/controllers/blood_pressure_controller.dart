import 'package:flutter/material.dart';
import '../models/blood_pressure_entry.dart';

class BloodPressureController extends ChangeNotifier {
  int _targetSystolic = 120;
  int _targetDiastolic = 80;
  final List<BloodPressureEntry> _history = [];

  int get targetSystolic => _targetSystolic;
  int get targetDiastolic => _targetDiastolic;
  List<BloodPressureEntry> get history => List.unmodifiable(_history);

  BloodPressureEntry? get latest => _history.isEmpty ? null : _history.first;

  double get pressureScore {
    if (latest == null) return 0;
    final sysScore = (_targetSystolic / latest!.systolic).clamp(0.0, 1.0);
    final diaScore = (_targetDiastolic / latest!.diastolic).clamp(0.0, 1.0);
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
    _history.insert(
      0,
      BloodPressureEntry(
        systolic: systolic,
        diastolic: diastolic,
        trigger: trigger,
        time: TimeOfDay.now(),
      ),
    );
    notifyListeners();
  }

  void updateTarget({required int systolic, required int diastolic}) {
    if (systolic < 90 || diastolic < 60) return;
    _targetSystolic = systolic;
    _targetDiastolic = diastolic;
    notifyListeners();
  }

  void removeEntry(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    notifyListeners();
  }
}
