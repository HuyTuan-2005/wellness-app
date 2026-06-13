import 'package:flutter/material.dart';
import '../controllers/nutrition_controller.dart';
import '../models/ai_nutrition_advice.dart';
import '../models/nutrition_entry.dart';

// ==========================================
// 2. AiMealSuggestionCard (Trang Ăn uống)
// ==========================================
class AiMealSuggestionCard extends StatefulWidget {
  final NutritionController controller;
  final MealType? currentMealType;
  final void Function(RecommendedMeal, MealType)? onAddMeal;

  const AiMealSuggestionCard({
    super.key,
    required this.controller,
    this.currentMealType,
    this.onAddMeal,
  });

  @override
  State<AiMealSuggestionCard> createState() => _AiMealSuggestionCardState();
}

class _AiMealSuggestionCardState extends State<AiMealSuggestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  String _selectedBudget = 'Trung bình';
  bool _hasClicked = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!_hasClicked) {
          return _buildIdleState();
        }

        final ctrl = widget.controller;

        if (ctrl.isLoadingAi) {
          return _buildLoadingState();
        }

        if (ctrl.aiError != null) {
          return _buildErrorState();
        }

        final advice = ctrl.aiAdvice;
        if (advice != null && advice.recommendedMeals.isNotEmpty) {
          return _buildResultState(advice);
        }

        // fallback if empty
        return _buildIdleState();
      },
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red.shade400),
              const SizedBox(width: 8),
              const Text(
                'Lỗi kết nối mạng',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Hệ thống AI không thể kết nối. Vui lòng kiểm tra lại mạng (Wi-Fi/4G) và thử lại sau.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A5568), height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.controller.fetchAiAdvice(budget: _selectedBudget);
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              const Text(
                'Gợi ý bữa ăn tiếp theo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Chọn mức chi phí cho bữa ăn gợi ý:',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Tiết kiệm', 'Trung bình', 'Cao cấp'].map((budget) {
              return ChoiceChip(
                label: Text(budget),
                selected: _selectedBudget == budget,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedBudget = budget;
                    });
                  }
                },
                selectedColor: Colors.teal.shade50,
                labelStyle: TextStyle(
                  color: _selectedBudget == budget ? Colors.teal.shade700 : Colors.grey.shade700,
                  fontWeight: _selectedBudget == budget ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasClicked = true;
                });
                widget.controller.fetchAiAdvice(budget: _selectedBudget);
              },
              icon: const Icon(Icons.bolt, color: Colors.white),
              label: const Text(
                'Nhận gợi ý món ăn',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI đang phân tích...',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerLine(width: double.infinity),
          const SizedBox(height: 8),
          _shimmerLine(width: 220),
          const SizedBox(height: 16),
          _shimmerLine(width: double.infinity, height: 60),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double width, double height = 12}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
              stops: [
                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultState(AiNutritionAdvice advice) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, size: 20, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                Text(
                  'Gợi ý bữa ăn tiếp theo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.teal.shade800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: Colors.teal,
                  onPressed: () {
                    setState(() { _hasClicked = false; });
                  },
                ),
              ],
            ),
          ),
          ...advice.recommendedMeals.map((meal) => _buildMealCard(meal)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMealCard(RecommendedMeal meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.name,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _macroBadge(Icons.local_fire_department, '${meal.calo} kcal', Colors.deepOrange),
                _macroBadge(Icons.fitness_center, 'P: ${meal.protein}g', const Color(0xFF667EEA)),
                _macroBadge(Icons.grain, 'C: ${meal.carb}g', Colors.amber.shade800),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.reason,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
            ),
            if (widget.currentMealType != null && widget.onAddMeal != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => widget.onAddMeal!(meal, widget.currentMealType!),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text('Thêm vào ${widget.currentMealType!.label}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _macroBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
