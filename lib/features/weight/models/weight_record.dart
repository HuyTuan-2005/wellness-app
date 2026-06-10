import 'package:flutter/material.dart';

class WeightRecord {
  final int? id;
  final double weight;
  final DateTime date;

  WeightRecord({
    this.id,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}
