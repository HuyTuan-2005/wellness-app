import 'package:flutter/material.dart';

class BloodPressureEntry {
  final int systolic;
  final int diastolic;
  final String trigger;
  final TimeOfDay time;

  BloodPressureEntry({
    required this.systolic,
    required this.diastolic,
    required this.trigger,
    required this.time,
  });
}
