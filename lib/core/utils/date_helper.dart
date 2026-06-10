import 'package:flutter/material.dart';

class DateHelper {
  static String getDateString() {
    final now = DateTime.now();
    const days = [
      'Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư',
      'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'
    ];
    return '${days[now.weekday % 7]}, ${now.day} tháng ${now.month}, ${now.year}';
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
