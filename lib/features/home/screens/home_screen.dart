import 'package:flutter/material.dart';
import 'package:wellness_app/features/appointment/screens/appointment_list_screen.dart';
import 'package:wellness_app/features/blood_pressure/screens/blood_pressure_tracking_screen.dart';
import 'package:wellness_app/features/medication/screens/medication_list_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/features/profile/screens/profile_screen.dart';
import 'package:wellness_app/features/BMI/screens/BMI_screen.dart';
import 'package:wellness_app/features/nutrition/screens/nutrition_tracking_screen.dart';
import 'package:wellness_app/features/sleep/screens/sleep_tracking_screen.dart';
import 'package:wellness_app/features/water/screens/water_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Hôm nay bạn khỏe mạnh chứ?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 32),

            // ==================== CÁC CARD ĐỒNG NHẤT ====================
            _FeatureCard(
              title: 'Tính chỉ số BMI',
              subtitle: 'Kiểm tra tình trạng cân nặng của bạn',
              icon: Icons.calculate_rounded,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BMICalculatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Theo dõi nước uống',
              subtitle: 'Ghi nhận lượng nước và tiến độ mỗi ngày',
              icon: Icons.water_drop_outlined,
              color: const Color(0xFF0288D1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaterTrackingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Theo dõi dinh dưỡng',
              subtitle: 'Quản lý calo, carb và protein theo bữa ăn',
              icon: Icons.restaurant_menu,
              color: const Color(0xFF2E7D32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NutritionTrackingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Theo dõi giấc ngủ',
              subtitle: 'Ghi nhận số giờ ngủ và mục tiêu',
              icon: Icons.bedtime_outlined,
              color: const Color(0xFF3949AB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SleepTrackingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Theo dõi huyết áp',
              subtitle: 'Theo dõi chỉ số và lịch sử đo',
              icon: Icons.favorite_outline,
              color: const Color(0xFFD32F2F),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BloodPressureTrackingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Lịch uống thuốc',
              subtitle: 'Ghi nhận thời gian và liều lượng thuốc',
              icon: Icons.medication_outlined,
              color: const Color(0xFF0288D1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MedicationListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _FeatureCard(
              title: 'Lịch hẹn bác sĩ',
              subtitle: 'Ghi nhận thời gian và địa điểm hẹn',
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFF0288D1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppointmentListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET CARD ĐỒNG NHẤT ====================
  Widget _FeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 18),

            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Icon mũi tên
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
