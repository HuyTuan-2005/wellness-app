import 'package:flutter/material.dart';

class BloodPressureEntry {
  int? id;
  int systolic;
  int diastolic;
  String trigger;
  String timeStr;
  String createdAtStr;
  String? userId;
  int isSynced;

  BloodPressureEntry({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.trigger,
    required this.timeStr,
    required this.createdAtStr,
    this.userId,
    this.isSynced = 0,
  });

  BloodPressureEntry.create({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.trigger,
    required TimeOfDay time,
    required DateTime createdAt,
    this.userId,
    this.isSynced = 0,
  })  : timeStr = '${time.hour}:${time.minute}',
        createdAtStr = createdAt.toIso8601String();

  TimeOfDay get time {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  DateTime get createdAt {
    try {
      return DateTime.parse(createdAtStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'trigger': trigger,
      'timeStr': timeStr,
      'createdAtStr': createdAtStr,
      'userId': userId,
      'isSynced': isSynced,
    };
  }

  factory BloodPressureEntry.fromMap(Map<String, dynamic> map) {
    return BloodPressureEntry(
      id: map['id'],
      systolic: map['systolic'] ?? 0,
      diastolic: map['diastolic'] ?? 0,
      trigger: map['trigger'] ?? '',
      timeStr: map['timeStr'] ?? '0:0',
      createdAtStr: map['createdAtStr'] ?? DateTime.now().toIso8601String(),
      userId: map['userId'],
      isSynced: map['isSynced'] ?? 0,
    );
  }
}
