import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/system_notifications/widgets/notification_icon_badge.dart';
import 'package:wellness_app/features/health/water/controllers/water_controller.dart';
import 'package:wellness_app/features/health/sleep/controllers/sleep_controller.dart';
import 'package:wellness_app/features/health/blood_pressure/controllers/blood_pressure_controller.dart';
import 'package:wellness_app/features/health/nutrition/controllers/nutrition_controller.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';

import 'package:wellness_app/features/health/water/screens/water_tracking_screen.dart';
import 'package:wellness_app/features/health/sleep/screens/sleep_tracking_screen.dart';
import 'package:wellness_app/features/health/blood_pressure/screens/blood_pressure_tracking_screen.dart';
import 'package:wellness_app/features/health/nutrition/screens/nutrition_tracking_screen.dart';
import 'package:wellness_app/features/health/weight/screens/weight_tracking_screen.dart';
import 'package:wellness_app/features/health/mental_health/screens/mental_health_tracking_screen.dart';
import 'package:wellness_app/features/health/BMI/screens/bmi_screen.dart';
import 'package:wellness_app/features/health/nutrition/widgets/ai_advice_card.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  // Khởi tạo các controller
  final WaterController _waterController = WaterController();
  final SleepController _sleepController = SleepController();
  final BloodPressureController _bpController = BloodPressureController();
  final NutritionController _nutritionController = NutritionController();

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu
    final waterValue = '${_waterController.currentMl} ml';
    final sleepValue = '${_sleepController.todayHours.toStringAsFixed(1)} giờ';
    final bpLatest = _bpController.latest;
    final bpValue = bpLatest != null
        ? '${bpLatest.systolic}/${bpLatest.diastolic}'
        : '--';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tổng quan Sức khỏe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          const NotificationIconBadge(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(context),
            const SizedBox(height: 24),
            AiHealthAdviceCard(
              controller: _nutritionController,
            ),
            const SizedBox(height: 24),
            _buildCardsSection(context, waterValue, sleepValue, bpValue),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    double currentCalo = _nutritionController.totalCalo;
    double targetCalo = _nutritionController.goalCalo.toDouble();
    double bmi = UserProfile.bmi;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tổng quan trong ngày',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Donut Chart cho Dinh dưỡng
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NutritionTrackingScreen(),
                ),
              ).then((_) => setState(() {}));
            },
            child: SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 65,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: Colors.orange,
                          value: currentCalo,
                          title: '',
                          radius: 12,
                        ),
                        PieChartSectionData(
                          color: Colors.grey.withValues(alpha: 0.2),
                          value: (targetCalo - currentCalo) > 0
                              ? (targetCalo - currentCalo)
                              : 0,
                          title: '',
                          radius: 12,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentCalo.toInt()}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '/ ${targetCalo.toInt()} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Thanh chỉ số BMI
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BMICalculatorScreen(),
                ),
              ).then((_) => setState(() {}));
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chỉ số BMI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double percentage;
                      if (bmi < 18.5) {
                        percentage = (bmi - 15) / (18.5 - 15) * 0.25;
                      } else if (bmi < 23.0) {
                        percentage = 0.25 + (bmi - 18.5) / (23.0 - 18.5) * 0.25;
                      } else if (bmi < 25.0) {
                        percentage = 0.5 + (bmi - 23.0) / (25.0 - 23.0) * 0.25;
                      } else {
                        percentage = 0.75 + (bmi - 25.0) / (30.0 - 25.0) * 0.25;
                      }
                      
                      if (percentage < 0.02) percentage = 0.02;
                      if (percentage > 0.98) percentage = 0.98;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(child: Container(color: Colors.green)),
                                Expanded(child: Container(color: Colors.orange)),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Mũi tên chỉ báo
                          Positioned(
                            left:
                                (constraints.maxWidth * percentage) -
                                12, // 12 là nửa chiều rộng của icon
                            top: -18,
                            child: const Icon(
                              Icons.arrow_drop_down,
                              size: 24,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thiếu cân',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Bình thường',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Thừa cân',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Béo phì',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(
    BuildContext context,
    String waterValue,
    String sleepValue,
    String bpValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê Chi tiết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            HealthSummaryCard(
              icon: Icons.water_drop,
              title: 'Nước uống',
              value: waterValue,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaterTrackingScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            HealthSummaryCard(
              icon: Icons.bedtime,
              title: 'Giấc ngủ',
              value: sleepValue,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SleepTrackingScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            HealthSummaryCard(
              icon: Icons.favorite,
              title: 'Huyết áp',
              value: bpValue,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BloodPressureTrackingScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            HealthSummaryCard(
              icon: Icons.monitor_weight,
              title: 'Cân nặng',
              value: '${UserProfile.weight.toStringAsFixed(1)} kg',
              color: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeightTrackingScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            HealthSummaryCard(
              icon: Icons.self_improvement,
              title: 'Tinh thần',
              value: 'Bình thường',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentalHealthTrackingScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class HealthSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const HealthSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

