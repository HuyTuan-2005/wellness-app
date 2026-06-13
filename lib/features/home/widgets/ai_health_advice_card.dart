import 'package:flutter/material.dart';
import 'package:wellness_app/features/health/nutrition/controllers/nutrition_controller.dart';
import 'package:wellness_app/features/health/nutrition/models/ai_nutrition_advice.dart';

// ==========================================
// 1. AiHealthAdviceCard (Trang chủ)
// ==========================================
class AiHealthAdviceCard extends StatefulWidget {
  final NutritionController controller;

  const AiHealthAdviceCard({
    super.key,
    required this.controller,
  });

  @override
  State<AiHealthAdviceCard> createState() => _AiHealthAdviceCardState();
}

class _AiHealthAdviceCardState extends State<AiHealthAdviceCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.aiAdvice == null && !widget.controller.isLoadingAi) {
        widget.controller.fetchAiAdvice(); // default budget
      }
    });
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

        if (ctrl.isLoadingAi) {
          return _buildLoadingState();
        }

        final advice = ctrl.aiAdvice;
        if (advice != null) {
          return _buildResultState(advice);
        }

        return _buildLoadingState();
      },
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
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double val = _shimmerController.value;
        final double pulse = val < 0.5 ? val * 2 : (1 - val) * 2;

        return Container(
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
                color: Colors.blue.shade200.withValues(alpha: 0.3 + 0.2 * pulse),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber.shade500),
                      const SizedBox(width: 8),
                      const Text(
                        'Sức khỏe AI',
                        style: TextStyle(
                          color: Color(0xFF2D3748),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
