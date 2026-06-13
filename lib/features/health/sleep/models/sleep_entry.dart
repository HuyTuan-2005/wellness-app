import 'package:flutter/material.dart';

class SleepEntry {
  int? id;
  String bedTimeStr;
  String wakeTimeStr;
  double hours;
  String createdAtStr;
  String? userId;
  int isSynced;

  SleepEntry({
    this.id,
    required this.bedTimeStr,
    required this.wakeTimeStr,
    required this.hours,
    required this.createdAtStr,
    this.userId,
    this.isSynced = 0,
  });

  SleepEntry.create({
    this.id,
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
    required this.hours,
    required DateTime createdAt,
    this.userId,
    this.isSynced = 0,
  })  : bedTimeStr = '${bedTime.hour}:${bedTime.minute}',
        wakeTimeStr = '${wakeTime.hour}:${wakeTime.minute}',
        createdAtStr = createdAt.toIso8601String();

  TimeOfDay get bedTime {
    try {
      final parts = bedTimeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  TimeOfDay get wakeTime {
    try {
      final parts = wakeTimeStr.split(':');
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
      'bedTimeStr': bedTimeStr,
      'wakeTimeStr': wakeTimeStr,
      'hours': hours,
      'createdAtStr': createdAtStr,
      'userId': userId,
      'isSynced': isSynced,
    };
  }

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'],
      bedTimeStr: map['bedTimeStr'] ?? '0:0',
      wakeTimeStr: map['wakeTimeStr'] ?? '0:0',
      hours: (map['hours'] ?? 0).toDouble(),
      createdAtStr: map['createdAtStr'] ?? DateTime.now().toIso8601String(),
      userId: map['userId'],
      isSynced: map['isSynced'] ?? 0,
    );
  }
}
