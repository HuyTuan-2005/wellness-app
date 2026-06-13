import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/features/health/sleep/controllers/sleep_controller.dart';
import 'package:wellness_app/features/health/blood_pressure/controllers/blood_pressure_controller.dart';
import 'package:wellness_app/data/services/gemini_nutrition_service.dart';
import '../data/food_database.dart';
import '../models/nutrition_entry.dart';
import '../models/ai_nutrition_advice.dart';

class NutritionController extends ChangeNotifier {
  // Singleton pattern
  static final NutritionController _instance = NutritionController._internal();
  factory NutritionController() => _instance;

  StreamSubscription? _subscription;
  String? _userId;
  String? _dateStr;

  final List<NutritionEntry> _history = [];

  // ==================== AI ADVICE STATE ====================
  AiNutritionAdvice? _aiAdvice;
  bool _isLoadingAi = false;
  String? _aiError;

  AiNutritionAdvice? get aiAdvice => _aiAdvice;
  bool get isLoadingAi => _isLoadingAi;
  String? get aiError => _aiError;

  NutritionController._internal() {
    // Nếu mục tiêu calo chưa được cấu hình, tự động tính calo gợi ý dựa trên cơ thể
    if (UserProfile.dailyCaloGoal == 2000) {
      UserProfile.dailyCaloGoal = getSuggestedCalories();
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _subscribeToToday();
      } else {
        _unsubscribe();
        _userId = null;
      }
    });
  }

  String _getTodayDateStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _subscribeToToday() {
    if (_userId == null) return;
    final today = _getTodayDateStr();
    _dateStr = today;

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('nutrition_logs')
        .doc(today)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final data = doc.data()!;
              final entriesData = data['entries'] as List<dynamic>? ?? [];
              _history.clear();
              for (var e in entriesData) {
                _history.add(NutritionEntry.fromMap(e));
              }
            } else {
              _history.clear();
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error listening to today's nutrition logs: $e");
          },
        );
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _history.clear();
    _dateStr = null;
    notifyListeners();
  }

  void _checkRollover() {
    if (_userId != null && _dateStr != _getTodayDateStr()) {
      _subscribeToToday();
    }
  }

  int get goalCalo => UserProfile.dailyCaloGoal;
  List<NutritionEntry> get history {
    _checkRollover();
    return List.unmodifiable(_history);
  }

  double get totalCalo {
    _checkRollover();
    return _history.fold(0.0, (tot, e) => tot + e.calo);
  }

  double get totalProtein {
    _checkRollover();
    return _history.fold(0.0, (tot, e) => tot + e.protein);
  }

  double get totalCarb {
    _checkRollover();
    return _history.fold(0.0, (tot, e) => tot + e.carb);
  }

  double get remainingCalo => (goalCalo - totalCalo).clamp(0, double.infinity);
  double get progress => (totalCalo / goalCalo).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();

  /// Tính lượng calo gợi ý dựa theo tỉ lệ cơ thể (Mifflin-St Jeor)
  int getSuggestedCalories() {
    return UserProfile.getSuggestedCaloriesFor(
      weight: UserProfile.weight,
      height: UserProfile.height,
      age: UserProfile.age,
      gender: UserProfile.gender,
    );
  }

  /// Kiểm tra xem món ăn có tần suất ăn >= 2 lần hay không
  bool isFrequent(String foodName) {
    _checkRollover();
    final name = foodName.trim().toLowerCase();
    final count = _history
        .where((e) => e.foodName.trim().toLowerCase() == name)
        .length;
    return count >= 2;
  }

  /// Gợi ý các món ăn bao gồm cả các món có tần suất ăn >= 2 bữa/ngày lên đầu
  List<FoodItem> suggestFood(String query) {
    _checkRollover();
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
        final matchingEntries = _history
            .where((e) => e.foodName.trim().toLowerCase() == name.toLowerCase())
            .toList();
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
          frequentFoods.add(
            FoodItem(
              name: name,
              caloPer100g: double.parse(
                (totalCalo100g / validCount).toStringAsFixed(1),
              ),
              proteinPer100g: double.parse(
                (totalProtein100g / validCount).toStringAsFixed(1),
              ),
              carbPer100g: double.parse(
                (totalCarb100g / validCount).toStringAsFixed(1),
              ),
            ),
          );
        }
      }
    });

    // 3. Kết hợp danh sách gợi ý (ưu tiên món ăn tần suất cao lên trước)
    final List<FoodItem> combined = [];
    combined.addAll(frequentFoods);

    final dbSuggestions = FoodDatabase.suggest(query);
    for (final dbFood in dbSuggestions) {
      final alreadyExists = combined.any(
        (f) => f.name.toLowerCase() == dbFood.name.toLowerCase(),
      );
      if (!alreadyExists) {
        combined.add(dbFood);
      }
    }

    // 4. Lọc theo từ khóa tìm kiếm
    if (query.isEmpty) {
      return frequentFoods;
    } else {
      final lower = query.toLowerCase();
      return combined
          .where((f) => f.name.toLowerCase().contains(lower))
          .toList();
    }
  }

  void updateGoal(int goalCalo) {
    if (goalCalo < 600) return;
    UserProfile.dailyCaloGoal = goalCalo;

    // Đồng bộ lên Firestore nếu user đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'dailyCaloGoal': goalCalo})
          .catchError(
            (e) => debugPrint('Lỗi cập nhật mục tiêu calo lên Firestore: $e'),
          );
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
    _checkRollover();
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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition_logs')
          .doc(_getTodayDateStr())
          .set({'entries': _history.map((e) => e.toMap()).toList()})
          .catchError(
            (e) => debugPrint("Error updating nutrition log to Firestore: $e"),
          );
    } else {
      notifyListeners();
    }
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
    _checkRollover();
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition_logs')
          .doc(_getTodayDateStr())
          .set({
        'entries': _history.map((e) => e.toMap()).toList(),
      }).catchError((e) => debugPrint("Error updating nutrition log in Firestore: $e"));
    } else {
      notifyListeners();
    }
  }



  // ==================== AI ADVICE METHODS ====================

  /// Lấy danh sách tên các món ăn có tần suất >= 2 lần.
  List<String> getFrequentFoodNames() {
    final Map<String, int> frequencies = {};
    for (final entry in _history) {
      final name = entry.foodName.trim();
      frequencies[name] = (frequencies[name] ?? 0) + 1;
    }
    return frequencies.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();
  }

  /// Gọi Gemini API để lấy lời khuyên dinh dưỡng cá nhân hóa.
  Future<void> fetchAiAdvice({String budget = 'Trung bình'}) async {
    if (_isLoadingAi) return;

    _isLoadingAi = true;
    _aiError = null;
    notifyListeners();

    try {
      final sleepCtrl = SleepController();
      final bpCtrl = BloodPressureController();

      // Thu thập dữ liệu giấc ngủ
      final sleepHours = sleepCtrl.latest?.hours ?? 0.0;

      // Thu thập dữ liệu huyết áp
      String bpStatus;
      final bpLatest = bpCtrl.latest;
      if (bpLatest != null) {
        final classification = bpCtrl.classify(bpLatest);
        bpStatus = '${bpLatest.systolic}/${bpLatest.diastolic} - $classification';
      } else {
        bpStatus = 'Chưa có dữ liệu';
      }

      // Gọi Gemini
      final advice = await GeminiNutritionService().getAdvice(
        currentWeight: UserProfile.weight,
        goalCalo: goalCalo,
        consumedCalo: totalCalo,
        consumedProtein: totalProtein,
        consumedCarb: totalCarb,
        remainingCalo: remainingCalo,
        sleepHours: sleepHours,
        bloodPressureStatus: bpStatus,
        frequentFoods: getFrequentFoodNames(),
        budget: budget,
      );

      _aiAdvice = advice;
      _isLoadingAi = false;
      notifyListeners();
    } catch (e) {
      _aiAdvice = AiNutritionAdvice.fallback;
      _aiError = e.toString();
      _isLoadingAi = false;
      notifyListeners();
    }
  }

  /// Xóa kết quả AI hiện tại.
  void clearAiAdvice() {
    _aiAdvice = null;
    _aiError = null;
    notifyListeners();
  }
}
