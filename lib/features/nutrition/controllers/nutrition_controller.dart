import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../data/food_database.dart';
import '../models/nutrition_entry.dart';

class NutritionController extends ChangeNotifier {
  // Singleton pattern
  static final NutritionController _instance = NutritionController._internal();
  factory NutritionController() => _instance;

  NutritionController._internal() {
    // Nếu mục tiêu calo chưa được cấu hình, tự động tính calo gợi ý dựa trên cơ thể
    if (UserProfile.dailyCaloGoal == 2000) {
      UserProfile.dailyCaloGoal = getSuggestedCalories();
    }
  }

  final List<NutritionEntry> _history = [];

  int get goalCalo => UserProfile.dailyCaloGoal;
  List<NutritionEntry> get history => List.unmodifiable(_history);

  double get totalCalo => _history.fold(0, (tot, e) => tot + e.calo);
  double get totalProtein => _history.fold(0, (tot, e) => tot + e.protein);
  double get totalCarb => _history.fold(0, (tot, e) => tot + e.carb);
  double get remainingCalo => (goalCalo - totalCalo).clamp(0, double.infinity);
  double get progress => (totalCalo / goalCalo).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();

  /// Tính lượng calo gợi ý dựa theo tỉ lệ cơ thể (Mifflin-St Jeor)
  int getSuggestedCalories() {
    double w = UserProfile.weight;
    double h = UserProfile.height;
    int a = UserProfile.age;
    String g = UserProfile.gender;

    double bmr;
    if (g == "Nam") {
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
    } else if (g == "Nữ") {
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * a - 78; // Trung bình giới tính khác
    }

    // TDEE = BMR * 1.375 (Mức độ vận động nhẹ nhàng)
    double tdee = bmr * 1.375;
    return tdee.round();
  }

  /// Kiểm tra xem món ăn có tần suất ăn >= 2 lần hay không
  bool isFrequent(String foodName) {
    final name = foodName.trim().toLowerCase();
    final count = _history.where((e) => e.foodName.trim().toLowerCase() == name).length;
    return count >= 2;
  }

  /// Gợi ý các món ăn bao gồm cả các món có tần suất ăn >= 2 bữa/ngày lên đầu
  List<FoodItem> suggestFood(String query) {
    // 1. Đếm tần suất các món ăn đã ăn trong lịch sử
    final Map<String, int> frequencies = {};
    for (final entry in _history) {
      final name = entry.foodName.trim();
      frequencies[name] = (frequencies[name] ?? 0) + 1;
    }

    // 2. Lọc ra các món ăn có tần suất >= 2
    final List<FoodItem> frequentFoods = [];
    frequencies.forEach((name, cnt) {
      if (cnt >= 2) {
        // Tìm các entries tương ứng để tính trung bình dinh dưỡng trên 100g
        final matchingEntries = _history.where((e) => e.foodName.trim().toLowerCase() == name.toLowerCase()).toList();
        double totalCalo100g = 0;
        double totalProtein100g = 0;
        double totalCarb100g = 0;
        int validCount = 0;

        for (final entry in matchingEntries) {
          if (entry.quantity > 0) {
            final factor = entry.quantity / 100.0;
            totalCalo100g += entry.calo / factor;
            totalProtein100g += entry.protein / factor;
            totalCarb100g += entry.carb / factor;
            validCount++;
          }
        }

        if (validCount > 0) {
          frequentFoods.add(FoodItem(
            name: name,
            caloPer100g: double.parse((totalCalo100g / validCount).toStringAsFixed(1)),
            proteinPer100g: double.parse((totalProtein100g / validCount).toStringAsFixed(1)),
            carbPer100g: double.parse((totalCarb100g / validCount).toStringAsFixed(1)),
          ));
        }
      }
    });

    // 3. Kết hợp danh sách gợi ý (ưu tiên món ăn tần suất cao lên trước)
    final List<FoodItem> combined = [];
    combined.addAll(frequentFoods);

    final dbSuggestions = FoodDatabase.suggest(query);
    for (final dbFood in dbSuggestions) {
      final alreadyExists = combined.any((f) => f.name.toLowerCase() == dbFood.name.toLowerCase());
      if (!alreadyExists) {
        combined.add(dbFood);
      }
    }

    // 4. Lọc theo từ khóa tìm kiếm
    if (query.isEmpty) {
      return frequentFoods;
    } else {
      final lower = query.toLowerCase();
      return combined.where((f) => f.name.toLowerCase().contains(lower)).toList();
    }
  }

  void updateGoal(int goalCalo) {
    if (goalCalo < 600) return;
    UserProfile.dailyCaloGoal = goalCalo;

    // Đồng bộ lên Firestore nếu user đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'dailyCaloGoal': goalCalo,
      }).catchError((e) => debugPrint('Lỗi cập nhật mục tiêu calo lên Firestore: $e'));
    }

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

  void removeEntry(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    notifyListeners();
  }
}
