import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wellness_app/features/nutrition/models/ai_nutrition_advice.dart';

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
Bạn là một Chuyên gia Y tế và Dinh dưỡng cá nhân tận tâm, chuyên nghiệp. Nhiệm vụ của bạn là phân tích các chỉ số cơ thể, thói quen sinh hoạt hàng ngày của người dùng và đưa ra những lời khuyên cũng như gợi ý thực đơn phù hợp nhất.

DỮ LIỆU ĐẦU VÀO CỦA NGƯỜI DÙNG HÔM NAY:
- Cân nặng hiện tại: $currentWeight kg.
- Mục tiêu calo trong ngày: $goalCalo kcal.
- Lượng calo đã nạp: ${consumedCalo.round()} kcal (Trong đó: Protein: ${consumedProtein.round()}g, Carb: ${consumedCarb.round()}g).
- Lượng calo còn thiếu: ${remainingCalo.round()} kcal.
- Thời lượng giấc ngủ đêm qua: $sleepHours giờ.
- Huyết áp gần nhất: $bloodPressureStatus (Ví dụ: 120/80 - Bình thường, 140/90 - Hơi cao).
- Các món ăn người dùng thường ăn: $frequentFoodsList.
- Mức chi phí/ngân sách mong muốn: $budget.

YÊU CẦU THỰC THI:
1. Đánh giá tổng quan (adviceText): PHẢI đi thẳng vào vấn đề (KHÔNG chào hỏi, KHÔNG vòng vo). Phân tích nhanh tình trạng calo, giấc ngủ, huyết áp và đưa ra hành động cụ thể cần làm ngay (TỐI ĐA 2-3 CÂU, DƯỚI 4 DÒNG). Lưu ý: Hành động và thực phẩm được khuyên PHẢI phù hợp với mức ngân sách "$budget", nhưng TUYỆT ĐỐI KHÔNG ĐƯỢC nhắc đến các từ như "ngân sách", "chi phí" hay "tiết kiệm/trung bình/cao cấp" trong câu trả lời. (Chỉ âm thầm chọn từ ngữ và món ăn phù hợp).
2. Gợi ý món ăn (recommendedMeals): Đề xuất đúng 2 món ăn cho bữa tiếp theo sao cho tổng lượng calo của 2 món xấp xỉ mức calo còn thiếu (${remainingCalo.round()} kcal).
   - Ưu tiên sử dụng các nguyên liệu từ danh sách món ăn thường ăn ($frequentFoodsList) nếu có thể.
   - Các món ăn phải hỗ trợ cải thiện tình trạng giấc ngủ và huyết áp hiện tại (ví dụ: mất ngủ thì ưu tiên thực phẩm giàu Magie/Tryptophan; huyết áp cao thì hạn chế Natri, tăng Kali).
   - ĐẶC BIỆT LƯU Ý: Nguyên liệu và món ăn gợi ý bắt buộc phải phù hợp với mức chi phí/ngân sách "$budget".
   - Đưa ra ước lượng Calo, Protein, Carb cho từng món ăn.

RÀNG BUỘC ĐẦU RA (QUAN TRỌNG):
Bạn BẮT BUỘC phải trả về kết quả dưới định dạng JSON thuần túy (không có markdown code block, không có lời dạo đầu, không có text dư thừa) theo đúng cấu trúc sau để hệ thống parse dữ liệu:

{
  "adviceText": "Nhận xét tổng quan của bạn ở đây...",
  "recommendedMeals": [
    {
      "name": "Tên món ăn 1",
      "calo": 0,
      "protein": 0,
      "carb": 0,
      "reason": "Giải thích sinh lý học ngắn gọn lý do chọn món này dựa trên giấc ngủ/huyết áp/calo của người dùng."
    },
    {
      "name": "Tên món ăn 2",
      "calo": 0,
      "protein": 0,
      "carb": 0,
      "reason": "Giải thích..."
    }
  ]
}
Kiểm soát rủi ro dữ liệu: Trong trường hợp API lỗi, hết quota, hoặc trả về cấu trúc sai, bạn nên set up giá trị mặc định cho adviceText (ví dụ: "Hệ thống AI đang tạm nghỉ ngơi, vui lòng uống đủ nước và ngủ sớm nhé!") và trả về danh sách rỗng cho recommendedMeals để UI không bị gián đoạn.
''';
  }
}
