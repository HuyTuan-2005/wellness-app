import 'package:flutter/material.dart';

enum MealType { sang, trua, toi }

extension MealTypeExtension on MealType {
  String get label {
    switch (this) {
      case MealType.sang:
        return 'Sáng';
      case MealType.trua:
        return 'Trưa';
      case MealType.toi:
        return 'Tối';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.sang:
        return Icons.wb_sunny_outlined;
      case MealType.trua:
        return Icons.wb_cloudy_outlined;
      case MealType.toi:
        return Icons.nightlight_outlined;
    }
  }
}

class FoodItem {
  final String name;
  final double caloPer100g;
  final double proteinPer100g;
  final double carbPer100g;

  const FoodItem({
    required this.name,
    required this.caloPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
  });
}

class NutritionEntry {
  final String foodName;
  final int quantity;
  final double calo;
  final double protein;
  final double carb;
  final MealType mealType;
  final TimeOfDay time;

  NutritionEntry({
    required this.foodName,
    required this.quantity,
    required this.calo,
    required this.protein,
    required this.carb,
    required this.mealType,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'quantity': quantity,
      'calo': calo,
      'protein': protein,
      'carb': carb,
      'mealType': mealType.name,
      'time': {'hour': time.hour, 'minute': time.minute},
    };
  }

  factory NutritionEntry.fromMap(Map<dynamic, dynamic> map) {
    final timeMap = map['time'] as Map<dynamic, dynamic>;
    final mealTypeName = map['mealType'] as String;
    final mealType = MealType.values.firstWhere(
      (e) => e.name == mealTypeName,
      orElse: () => MealType.sang,
    );
    return NutritionEntry(
      foodName: map['foodName'] ?? '',
      quantity: (map['quantity'] as num).toInt(),
      calo: (map['calo'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carb: (map['carb'] as num).toDouble(),
      mealType: mealType,
      time: TimeOfDay(
        hour: (timeMap['hour'] as num).toInt(),
        minute: (timeMap['minute'] as num).toInt(),
      ),
    );
  }
}
