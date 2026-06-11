import 'package:flutter/material.dart';

class BloodPressureEntry {
  final String? id;
  final int systolic;
  final int diastolic;
  final String trigger;
  final TimeOfDay time;
  final DateTime createdAt;

  BloodPressureEntry({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.trigger,
    required this.time,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'trigger': trigger,
      'time': {'hour': time.hour, 'minute': time.minute},
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BloodPressureEntry.fromMap(String id, Map<String, dynamic> map) {
    final timeMap = map['time'] as Map<dynamic, dynamic>;
    return BloodPressureEntry(
      id: id,
      systolic: (map['systolic'] as num).toInt(),
      diastolic: (map['diastolic'] as num).toInt(),
      trigger: map['trigger'] ?? '',
      time: TimeOfDay(
        hour: (timeMap['hour'] as num).toInt(),
        minute: (timeMap['minute'] as num).toInt(),
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
