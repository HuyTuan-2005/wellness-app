import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:wellness_app/features/health/blood_pressure/models/blood_pressure_entry.dart';
import 'package:wellness_app/features/health/blood_pressure/controllers/blood_pressure_controller.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    UserProfile.resetToDefault();
  });

  group('BloodPressureEntry Tests', () {
    test('toMap should convert entry correctly', () {
      final entry = BloodPressureEntry(
        id: '123',
        systolic: 120,
        diastolic: 80,
        trigger: 'Sau khi ăn',
        time: const TimeOfDay(hour: 8, minute: 30),
        createdAt: DateTime.parse('2026-06-13T08:30:00.000'),
      );

      final map = entry.toMap();

      expect(map['systolic'], 120);
      expect(map['diastolic'], 80);
      expect(map['trigger'], 'Sau khi ăn');
      expect(map['time'], {'hour': 8, 'minute': 30});
      expect(map['createdAt'], '2026-06-13T08:30:00.000');
    });

    test('fromMap should construct entry correctly', () {
      final map = {
        'systolic': 130,
        'diastolic': 85,
        'trigger': 'Sau khi tập thể dục',
        'time': {'hour': 18, 'minute': 15},
        'createdAt': '2026-06-13T18:15:00.000',
      };

      final entry = BloodPressureEntry.fromMap('abc', map);

      expect(entry.id, 'abc');
      expect(entry.systolic, 130);
      expect(entry.diastolic, 85);
      expect(entry.trigger, 'Sau khi tập thể dục');
      expect(entry.time.hour, 18);
      expect(entry.time.minute, 15);
      expect(entry.createdAt, DateTime.parse('2026-06-13T18:15:00.000'));
    });
  });

  group('BloodPressureController Classification & Severity Tests', () {
    late BloodPressureController controller;

    setUp(() {
      controller = BloodPressureController();
    });

    test('classify blood pressure ranges', () {
      // Normal ranges
      final normal = BloodPressureEntry(
        systolic: 120,
        diastolic: 80,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      expect(controller.classify(normal), 'Bình thường');

      // Low ranges (systolic < 90 or diastolic < 60)
      final lowSys = BloodPressureEntry(
        systolic: 85,
        diastolic: 70,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final lowDia = BloodPressureEntry(
        systolic: 100,
        diastolic: 55,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      expect(controller.classify(lowSys), 'Thấp');
      expect(controller.classify(lowDia), 'Thấp');

      // High ranges (systolic >= 140 or diastolic >= 90)
      final highSys = BloodPressureEntry(
        systolic: 140,
        diastolic: 80,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final highDia = BloodPressureEntry(
        systolic: 120,
        diastolic: 95,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      expect(controller.classify(highSys), 'Cao');
      expect(controller.classify(highDia), 'Cao');
    });

    test('statusColorFor maps correctly', () {
      final normal = BloodPressureEntry(
        systolic: 120,
        diastolic: 80,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final low = BloodPressureEntry(
        systolic: 85,
        diastolic: 55,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final high = BloodPressureEntry(
        systolic: 145,
        diastolic: 95,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );

      expect(controller.statusColorFor(normal), Colors.green);
      expect(controller.statusColorFor(low), Colors.orange);
      expect(controller.statusColorFor(high), Colors.red);
    });

    test('dangerMessageFor triggers at extremes', () {
      final safe = BloodPressureEntry(
        systolic: 120,
        diastolic: 80,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );

      final dangerouslyHighSys = BloodPressureEntry(
        systolic: 180,
        diastolic: 80,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final dangerouslyHighDia = BloodPressureEntry(
        systolic: 120,
        diastolic: 120,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );

      final dangerouslyLowSys = BloodPressureEntry(
        systolic: 75,
        diastolic: 60,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );
      final dangerouslyLowDia = BloodPressureEntry(
        systolic: 90,
        diastolic: 45,
        trigger: 'Test',
        time: TimeOfDay.now(),
        createdAt: DateTime.now(),
      );

      expect(controller.dangerMessageFor(safe), isNull);
      expect(controller.dangerMessageFor(dangerouslyHighSys), isNotNull);
      expect(controller.dangerMessageFor(dangerouslyHighDia), isNotNull);
      expect(controller.dangerMessageFor(dangerouslyLowSys), isNotNull);
      expect(controller.dangerMessageFor(dangerouslyLowDia), isNotNull);
    });
  });

  group('BloodPressureController State Management Tests', () {
    test('Initial empty state and calculations', () {
      final controller = BloodPressureController();
      // Since it's a singleton, let's clear previous test data if any
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      expect(controller.history, isEmpty);
      expect(controller.latest, isNull);
      expect(controller.pressureScore, 0.0);
      expect(controller.statusText, 'Chưa có dữ liệu');
    });

    test('Add reading updates state and notifies listener', () {
      final controller = BloodPressureController();
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      var listenerCalled = false;
      controller.addListener(() {
        listenerCalled = true;
      });

      controller.addReading(systolic: 120, diastolic: 80, trigger: 'Tự nhiên');

      expect(listenerCalled, isTrue);
      expect(controller.history.length, 1);
      expect(controller.latest!.systolic, 120);
      expect(controller.latest!.diastolic, 80);
      expect(controller.latest!.trigger, 'Tự nhiên');
      expect(controller.statusText, 'Bình thường');

      // Default target in UserProfile is 120/80
      // sysScore = (120 / 120).clamp(0,1) = 1.0
      // diaScore = (80 / 80).clamp(0,1) = 1.0
      // pressureScore = (1.0 + 1.0)/2 = 1.0
      expect(controller.pressureScore, 1.0);
    });

    test('Multiple readings ordered descending (newest first)', () {
      final controller = BloodPressureController();
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      controller.addReading(systolic: 120, diastolic: 80, trigger: 'First');
      controller.addReading(systolic: 130, diastolic: 85, trigger: 'Second');

      expect(controller.history.length, 2);
      expect(controller.latest!.trigger, 'Second');
      expect(controller.history[0].trigger, 'Second');
      expect(controller.history[1].trigger, 'First');
    });

    test('Pressure score calculation clamping and logic', () {
      final controller = BloodPressureController();
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      UserProfile.targetSystolic = 120;
      UserProfile.targetDiastolic = 80;

      // Higher blood pressure should reduce the score
      controller.addReading(systolic: 150, diastolic: 100, trigger: 'High');

      // sysScore = (120 / 150).clamp(0,1) = 0.8
      // diaScore = (80 / 100).clamp(0,1) = 0.8
      // expected pressureScore = 0.8
      expect(controller.pressureScore, closeTo(0.8, 0.001));

      // Extremely high blood pressure should clamp to correct values
      controller.addReading(systolic: 300, diastolic: 200, trigger: 'Extreme');
      // sysScore = (120 / 300).clamp(0,1) = 0.4
      // diaScore = (80 / 200).clamp(0,1) = 0.4
      // expected pressureScore = 0.4
      expect(controller.pressureScore, closeTo(0.4, 0.001));
    });

    test('Update target values', () async {
      final controller = BloodPressureController();
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      await controller.updateTarget(systolic: 130, diastolic: 85);
      expect(controller.targetSystolic, 130);
      expect(controller.targetDiastolic, 85);
      expect(UserProfile.targetSystolic, 130);
      expect(UserProfile.targetDiastolic, 85);

      // Attempt to set invalid target should be ignored
      await controller.updateTarget(systolic: 80, diastolic: 50);
      expect(controller.targetSystolic, 130); // remains unchanged
      expect(controller.targetDiastolic, 85);
    });

    test('Remove reading', () async {
      final controller = BloodPressureController();
      while (controller.history.isNotEmpty) {
        controller.removeEntry(0);
      }

      controller.addReading(systolic: 120, diastolic: 80, trigger: 'First');
      controller.addReading(systolic: 130, diastolic: 85, trigger: 'Second');

      expect(controller.history.length, 2);

      await controller.removeEntry(0); // removes 'Second'
      expect(controller.history.length, 1);
      expect(controller.latest!.trigger, 'First');

      // Out of bounds index should do nothing
      await controller.removeEntry(5);
      expect(controller.history.length, 1);
    });
  });
}
