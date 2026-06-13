import 'package:flutter/material.dart';
import '../controllers/nutrition_controller.dart';
import '../models/ai_nutrition_advice.dart';

import '../models/nutrition_entry.dart';

/// Widget hiển thị lời khuyên dinh dưỡng từ Gemini AI.
///
/// Có 3 trạng thái:
/// - Đang tải: skeleton loading animation (tự động gọi khi mở màn hình)
/// - Kết quả: card hiển thị adviceText + 2 món ăn gợi ý
/// - Lỗi: hiển thị message mặc định thân thiện + nút retry
class AiAdviceCard extends StatefulWidget {
  final NutritionController controller;
  final bool showAdviceText;
  final bool showRecommendedMeals;
  final MealType? currentMealType;
  final void Function(RecommendedMeal, MealType)? onAddMeal;
  final bool autoFetch;

  const AiAdviceCard({
    super.key,
    required this.controller,
    this.showAdviceText = true,
    this.showRecommendedMeals = true,
    this.currentMealType,
    this.onAddMeal,
    this.autoFetch = false,
  });

  @override
  State<AiAdviceCard> createState() => _AiAdviceCardState();
}

class _AiAdviceCardState extends State<AiAdviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  String _selectedBudget = 'Trung bình';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    if (widget.autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.controller.aiAdvice == null && !widget.controller.isLoadingAi) {
          widget.controller.fetchAiAdvice(budget: _selectedBudget);
        }
      });
    }
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
        final ctrl = widget.controller;

        // Đang tải
        if (ctrl.isLoadingAi) {
          return _buildLoadingState();
        }

        // Có kết quả
        final advice = ctrl.aiAdvice;
        if (advice != null) {
          return _buildResultState(advice);
        }

        // Chưa gọi - hiển thị nút (nếu không autoFetch)
        if (widget.autoFetch) {
          return _buildLoadingState();
        }
        return _buildIdleState();
      },
    );
  }

  // ==================== TRẠNG THÁI: CHỜ (NÚT BẤM) ====================

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
              Icon(Icons.auto_awesome, color: Colors.amber.shade500),
              const SizedBox(width: 8),
              const Text(
                'Sức khỏe AI',
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
                selectedColor: Colors.blue.shade50,
                labelStyle: TextStyle(
                  color: _selectedBudget == budget
                      ? Colors.blue.shade700
                      : Colors.grey.shade700,
                  fontWeight: _selectedBudget == budget
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.controller.fetchAiAdvice(budget: _selectedBudget);
              },
              icon: const Icon(Icons.bolt, color: Colors.white),
              label: const Text(
                'Nhận gợi ý món ăn',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TRẠNG THÁI: ĐANG TẢI ====================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withValues(alpha: 0.2),
        ),
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
                    colors: [
                      Colors.blue.shade400,
                      Colors.teal.shade400,
                      Colors.amber.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI đang phân tích...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Shimmer loading lines
          ..._buildShimmerLines(),
        ],
      ),
    );
  }

  List<Widget> _buildShimmerLines() {
    return [
      _shimmerLine(width: double.infinity),
      const SizedBox(height: 8),
      _shimmerLine(width: 220),
      const SizedBox(height: 16),
      _shimmerLine(width: 180, height: 14),
      const SizedBox(height: 8),
      _shimmerLine(width: double.infinity, height: 60),
      const SizedBox(height: 8),
      _shimmerLine(width: double.infinity, height: 60),
    ];
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
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
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

  // ==================== TRẠNG THÁI: KẾT QUẢ ====================

  Widget _buildResultState(AiNutritionAdvice advice) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double val = _shimmerController.value;
        final double pulse = val < 0.5 ? val * 2 : (1 - val) * 2;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400.withValues(alpha: 0.8),
                    Colors.amber.shade400.withValues(alpha: 0.8),
                    Colors.green.shade400.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withValues(
                      alpha: 0.3 + 0.2 * pulse,
                    ), // Bóng đổ nhỏ hơn
                    blurRadius: 10 + 5 * pulse,
                    spreadRadius: 1 + 1 * pulse,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: child,
              ),
            ),

            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade500,
                  size: 28,
                ),
              ),
            ),
          ],
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
            child: Text(
              'Sức khỏe AI',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),

          if (widget.showAdviceText)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Text(
                advice.adviceText,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF4A5568),
                ),
              ),
            ),

          if (widget.showRecommendedMeals &&
              advice.recommendedMeals.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: widget.showAdviceText ? 0 : 8,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 18,
                    color: Colors.teal.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Gợi ý bữa ăn tiếp theo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...advice.recommendedMeals.map((meal) => _buildMealCard(meal)),
            const SizedBox(height: 16),
          ],
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
          border: Border.all(
            color: Colors.orange.shade200.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên món ăn
            Text(
              meal.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
            ),
            const SizedBox(height: 8),

            // Macro badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _macroBadge(
                  Icons.local_fire_department,
                  '${meal.calo} kcal',
                  Colors.deepOrange,
                ),
                _macroBadge(
                  Icons.fitness_center,
                  'P: ${meal.protein}g',
                  const Color(0xFF667EEA),
                ),
                _macroBadge(
                  Icons.grain,
                  'C: ${meal.carb}g',
                  Colors.amber.shade800,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lý do
            Text(
              meal.reason,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (widget.currentMealType != null && widget.onAddMeal != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () =>
                      widget.onAddMeal!(meal, widget.currentMealType!),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text('Thêm vào ${widget.currentMealType!.label}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
