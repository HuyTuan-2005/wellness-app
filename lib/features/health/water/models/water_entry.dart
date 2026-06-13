import 'package:flutter/material.dart';

class WaterEntry {
  int? id;
  int ml;
  String date; // ISO8601 string containing both date and time
  String? userId;
  int isSynced;

  WaterEntry({
    this.id,
    required this.ml,
    required this.date,
    this.userId,
    this.isSynced = 0,
  });

  // Getter giúp tương thích ngược với UI cũ không cần sửa đổi (Yêu cầu tuyệt đối không sửa giao diện)
  TimeOfDay get time {
    try {
      DateTime dt = DateTime.parse(date).toLocal();
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ml': ml,
      'date': date,
      'userId': userId,
      'isSynced': isSynced,
    };
  }

  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      id: map['id'],
      ml: map['ml'],
      date: map['date'],
      userId: map['userId'],
      isSynced: map['isSynced'] ?? 0,
    );
  }
}
