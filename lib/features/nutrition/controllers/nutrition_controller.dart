import 'package:flutter/material.dart';
import '../data/food_database.dart';
import '../models/nutrition_entry.dart';

class NutritionController extends ChangeNotifier {
  int _goalCalo = 2000;
  final List<NutritionEntry> _history = [];

  int get goalCalo => _goalCalo;
  List<NutritionEntry> get history => List.unmodifiable(_history);

  double get totalCalo => _history.fold(0, (sum, e) => sum + e.calo);
  double get totalProtein => _history.fold(0, (sum, e) => sum + e.protein);
  double get totalCarb => _history.fold(0, (sum, e) => sum + e.carb);
  double get remainingCalo => (_goalCalo - totalCalo).clamp(0, double.infinity);
  double get progress => (totalCalo / _goalCalo).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();

  List<FoodItem> suggestFood(String query) => FoodDatabase.suggest(query);

  void updateGoal(int goalCalo) {
    if (goalCalo < 600) return;
    _goalCalo = goalCalo;
    notifyListeners();
  }

  void addEntry({
    required String foodName,
    required int quantity,
    required double calo,
    required double protein,
    required double carb,
    required MealType mealType,
  }) {
    _history.insert(
      0,
      NutritionEntry(
        foodName: foodName,
        quantity: quantity,
        calo: calo,
        protein: protein,
        carb: carb,
        mealType: mealType,
        time: TimeOfDay.now(),
      ),
    );
    notifyListeners();
  }

  void addFromDatabase({
    required FoodItem food,
    required int quantity,
    required MealType mealType,
  }) {
    final factor = quantity / 100;
    addEntry(
      foodName: food.name,
      quantity: quantity,
      calo: food.caloPer100g * factor,
      protein: food.proteinPer100g * factor,
      carb: food.carbPer100g * factor,
      mealType: mealType,
    );
  }
}
