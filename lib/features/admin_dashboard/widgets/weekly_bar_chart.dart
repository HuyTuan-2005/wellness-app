import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

/// Widget biểu đồ cột giả lập hiển thị thống kê theo tuần.
/// Vẽ bằng Container thuần, không cần thư viện ngoài.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data: giá trị mỗi ngày trong tuần (0.0 → 1.0)
    final List<_BarData> bars = [
      _BarData('T2', 0.45, 12),
      _BarData('T3', 0.72, 19),
      _BarData('T4', 0.58, 15),
      _BarData('T5', 0.90, 24),
      _BarData('T6', 0.65, 17),
      _BarData('T7', 0.80, 21),
      _BarData('CN', 0.35, 9),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lượt truy cập tuần',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tuần 02/06 – 08/06/2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Trục Y labels + Bars
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // Trục Y
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _YLabel('25'),
                    _YLabel('20'),
                    _YLabel('15'),
                    _YLabel('10'),
                    _YLabel('5'),
                    _YLabel('0'),
                  ],
                ),
                const SizedBox(width: 12),

                // Khu vực biểu đồ
                Expanded(
                  child: Column(
                    children: [
                      // Các cột
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: bars.map((bar) {
                            return Expanded(
                              child: _AnimatedBar(
                                value: bar.fraction,
                                count: bar.count,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Trục X labels
                      Row(
                        children: bars.map((bar) {
                          return Expanded(
                            child: Text(
                              bar.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget nhãn trục Y – tách riêng để dùng const
class _YLabel extends StatelessWidget {
  final String text;
  const _YLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Dữ liệu biểu đồ cho từng cột
class _BarData {
  final String label;
  final double fraction; // 0.0 → 1.0
  final int count;
  _BarData(this.label, this.fraction, this.count);
}

/// Cột biểu đồ có animation khi xuất hiện
class _AnimatedBar extends StatefulWidget {
  final double value;
  final int count;

  const _AnimatedBar({
    required this.value,
    required this.count,
  });

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    // Delay nhẹ để tạo hiệu ứng stagger giữa các cột
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighest = widget.value >= 0.85;

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Giá trị số hiển thị trên cột
              Text(
                widget.count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isHighest ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Cột bar
              Container(
                height: _heightAnimation.value * 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isHighest
                        ? [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ]
                        : [
                            AppColors.primary.withValues(alpha: 0.6),
                            AppColors.primary.withValues(alpha: 0.2),
                          ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
