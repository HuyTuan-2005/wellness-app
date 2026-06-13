import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellness_app/features/health/sleep/controllers/sleep_controller.dart';

void main() {
  group('Kiểm thử logic tính toán giấc ngủ (Sleep Duration Tests)', () {
    test('Ngủ trong ngày (Không qua nửa đêm): 13:00 -> 15:30 (2.5 giờ)', () {
      final bedTime = const TimeOfDay(hour: 13, minute: 0);
      final wakeTime = const TimeOfDay(hour: 15, minute: 30);

      final result = SleepController.calculateDuration(bedTime: bedTime, wakeTime: wakeTime);
      expect(result, 2.5);
    });

    test('Ngủ qua nửa đêm: 22:30 -> 06:15 hôm sau (7.75 giờ)', () {
      final bedTime = const TimeOfDay(hour: 22, minute: 30);
      final wakeTime = const TimeOfDay(hour: 6, minute: 15);

      final result = SleepController.calculateDuration(bedTime: bedTime, wakeTime: wakeTime);
      expect(result, 7.75);
    });

    test('Ngủ sát giờ qua nửa đêm: 23:59 -> 00:01 hôm sau (~0.03 giờ)', () {
      final bedTime = const TimeOfDay(hour: 23, minute: 59);
      final wakeTime = const TimeOfDay(hour: 0, minute: 1);

      final result = SleepController.calculateDuration(bedTime: bedTime, wakeTime: wakeTime);
      expect(result, closeTo(0.033, 0.001));
    });

    test('Giờ thức dậy sát giờ ngủ: 08:00 -> 08:01 (0.016 giờ)', () {
      final bedTime = const TimeOfDay(hour: 8, minute: 0);
      final wakeTime = const TimeOfDay(hour: 8, minute: 1);

      final result = SleepController.calculateDuration(bedTime: bedTime, wakeTime: wakeTime);
      expect(result, closeTo(0.0167, 0.001));
    });
  });
}
