/// Data model cho kết quả tư vấn dinh dưỡng từ AI.
///
/// [AiNutritionAdvice] chứa lời khuyên tổng quan và danh sách món ăn gợi ý
/// được parse từ JSON response của Gemini API.
class AiNutritionAdvice {
  final String adviceText;
  final List<RecommendedMeal> recommendedMeals;

  const AiNutritionAdvice({
    required this.adviceText,
    required this.recommendedMeals,
  });

  /// Giá trị mặc định khi API lỗi hoặc không khả dụng.
  static const AiNutritionAdvice fallback = AiNutritionAdvice(
    adviceText:
        'Hệ thống AI đang tạm nghỉ ngơi, vui lòng uống đủ nước và ngủ sớm nhé!',
    recommendedMeals: [],
  );

  /// Parse từ JSON Map trả về bởi Gemini API.
  factory AiNutritionAdvice.fromJson(Map<String, dynamic> json) {
    try {
      final meals = (json['recommendedMeals'] as List<dynamic>?)
              ?.map((m) => RecommendedMeal.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      return AiNutritionAdvice(
        adviceText: json['adviceText'] as String? ?? fallback.adviceText,
        recommendedMeals: meals,
      );
    } catch (_) {
      return fallback;
    }
  }
}

/// Một món ăn được AI gợi ý.
class RecommendedMeal {
  final String name;
  final int calo;
  final int protein;
  final int carb;
  final String reason;

  const RecommendedMeal({
    required this.name,
    required this.calo,
    required this.protein,
    required this.carb,
    required this.reason,
  });

  factory RecommendedMeal.fromJson(Map<String, dynamic> json) {
    return RecommendedMeal(
      name: json['name'] as String? ?? 'Không rõ',
      calo: (json['calo'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carb: (json['carb'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
    );
  }
}
