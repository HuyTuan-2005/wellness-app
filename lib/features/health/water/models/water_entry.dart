import 'package:flutter/material.dart';

class WaterEntry {
  final int ml;
  final TimeOfDay time;

  WaterEntry({required this.ml, required this.time});

  Map<String, dynamic> toMap() {
    return {
      'ml': ml,
      'time': {'hour': time.hour, 'minute': time.minute},
    };
  }

  factory WaterEntry.fromMap(Map<dynamic, dynamic> map) {
    final timeMap = map['time'] as Map<dynamic, dynamic>;
    return WaterEntry(
      ml: (map['ml'] as num).toInt(),
      time: TimeOfDay(
        hour: (timeMap['hour'] as num).toInt(),
        minute: (timeMap['minute'] as num).toInt(),
      ),
    );
  }
}
