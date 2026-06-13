import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wellness_app/features/health/nutrition/models/ai_nutrition_advice.dart';

/// Service giao tiếp với Gemini API để nhận tư vấn dinh dưỡng cá nhân hóa.
///
/// API key được đọc an toàn từ file `.env` (key: `GEMINI_API_KEY`).
/// Xây dựng prompt từ dữ liệu sức khỏe người dùng, gửi tới Gemini,
/// và parse kết quả JSON. Xử lý mọi trường hợp lỗi với giá trị fallback.
class GeminiNutritionService {
  static final GeminiNutritionService _instance = GeminiNutritionService._();
  factory GeminiNutritionService() => _instance;
  GeminiNutritionService._();

  GenerativeModel? _model;

  /// Lấy API key từ file .env
  String? get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty || key == 'YOUR_GEMINI_API_KEY_HERE') {
      return null;
    }
    return key;
  }

  GenerativeModel? _getModel() {
    final apiKey = _apiKey;
    if (apiKey == null) return null;

    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json',
      ),
    );
    return _model;
  }

  // ==================== MAIN API CALL ====================

  /// Gọi Gemini API với dữ liệu sức khỏe người dùng.
  ///
  /// Trả về [AiNutritionAdvice] nếu thành công, hoặc giá trị fallback nếu lỗi.
  Future<AiNutritionAdvice> getAdvice({
    required double currentWeight,
    required int goalCalo,
    required double consumedCalo,
    required double consumedProtein,
    required double consumedCarb,
    required double remainingCalo,
    required double sleepHours,
    required String bloodPressureStatus,
    required List<String> frequentFoods,
    required String budget,
  }) async {
    try {
      final model = _getModel();
      if (model == null) {
        debugPrint(
          '⚠️ GeminiNutritionService: GEMINI_API_KEY chưa được cấu hình trong .env',
        );
        return AiNutritionAdvice.fallback;
      }

      final prompt = _buildPrompt(
        currentWeight: currentWeight,
        goalCalo: goalCalo,
        consumedCalo: consumedCalo,
        consumedProtein: consumedProtein,
        consumedCarb: consumedCarb,
        remainingCalo: remainingCalo,
        sleepHours: sleepHours,
        bloodPressureStatus: bloodPressureStatus,
        frequentFoods: frequentFoods,
        budget: budget,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;
      if (text == null || text.isEmpty) {
        debugPrint('⚠️ GeminiNutritionService: Response rỗng');
        return AiNutritionAdvice.fallback;
      }

      // Parse JSON từ response
      final json = _extractJson(text);
      if (json == null) {
        debugPrint('⚠️ GeminiNutritionService: Không parse được JSON');
        return AiNutritionAdvice.fallback;
      }

      return AiNutritionAdvice.fromJson(json);
    } catch (e) {
      debugPrint('❌ GeminiNutritionService error: $e');
      return AiNutritionAdvice.fallback;
    }
  }

  // ==================== JSON PARSING ====================

  /// Trích xuất JSON từ response text (có thể chứa markdown code block).
  Map<String, dynamic>? _extractJson(String text) {
    try {
      // Thử parse trực tiếp trước
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      // Nếu response chứa markdown code block, trích xuất JSON bên trong
      try {
        final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
        final match = regex.firstMatch(text);
        if (match != null) {
          return jsonDecode(match.group(1)!) as Map<String, dynamic>;
        }
      } catch (_) {}

      // Thử tìm { ... } pattern
      try {
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}');
        if (start != -1 && end > start) {
          return jsonDecode(text.substring(start, end + 1))
              as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    return null;
  }

  // ==================== PROMPT BUILDER ====================

  String _buildPrompt({
    required double currentWeight,
    required int goalCalo,
    required double consumedCalo,
    required double consumedProtein,
    required double consumedCarb,
    required double remainingCalo,
    required double sleepHours,
    required String bloodPressureStatus,
    required List<String> frequentFoods,
    required String budget,
  }) {
    final frequentFoodsList = frequentFoods.isEmpty
        ? 'Không có dữ liệu'
        : frequentFoods.join(', ');

    return '''
Bạn là Chuyên gia Dinh dưỡng cá nhân. Nhiệm vụ: Phân tích chỉ số, thói quen và đưa ra lời khuyên & thực đơn phù hợp.

[DỮ LIỆU ĐẦU VÀO]
- Cân nặng: $currentWeight kg
- Calo mục tiêu: $goalCalo kcal
- Đã nạp: ${consumedCalo.round()} kcal (Protein: ${consumedProtein.round()}g, Carb: ${consumedCarb.round()}g)
- Còn thiếu: ${remainingCalo.round()} kcal
- Giấc ngủ: $sleepHours giờ
- Huyết áp: $bloodPressureStatus
- Thường ăn: $frequentFoodsList
- Ngân sách: $budget

[YÊU CẦU]
1. adviceText: Đánh giá nhanh tình trạng calo, giấc ngủ, huyết áp và đưa ra hành động cụ thể (Tối đa 2-3 câu). Không chào hỏi, đi thẳng vào vấn đề. KHÔNG nhắc đến các từ "ngân sách", "chi phí" trong câu trả lời (chỉ chọn từ ngữ và thực phẩm phù hợp với mức ngân sách "$budget").
2. recommendedMeals: Đề xuất đúng 2 món ăn cho bữa tiếp theo (tổng calo xấp xỉ ${remainingCalo.round()} kcal).
   - Ưu tiên sử dụng nguyên liệu trong danh sách món thường ăn.
   - Hỗ trợ cải thiện giấc ngủ và huyết áp hiện tại.
   - Bắt buộc phù hợp với ngân sách "$budget".

[RÀNG BUỘC ĐẦU RA]
Trả về MỘT chuỗi JSON thuần túy, tuyệt đối KHÔNG có markdown code block, KHÔNG có lời dạo đầu, KHÔNG có text dư thừa bên ngoài JSON:
{
  "adviceText": "Nhận xét tổng quan của bạn...",
  "recommendedMeals": [
    {
      "name": "Tên món",
      "calo": 0,
      "protein": 0,
      "carb": 0,
      "reason": "Lý do chọn món."
    }
  ]
}
''';
  }
}
