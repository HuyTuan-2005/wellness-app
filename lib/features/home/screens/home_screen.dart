import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:wellness_app/features/blood_pressure/screens/blood_pressure_tracking_screen.dart';
import 'package:wellness_app/features/nutrition/screens/nutrition_tracking_screen.dart';
import 'package:wellness_app/features/sleep/screens/sleep_tracking_screen.dart';
import 'package:wellness_app/features/water/screens/water_tracking_screen.dart';
=======
import 'package:wellness_app/features/BMI/screens/BMI_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/features/profile/screens/profile_screen.dart';
>>>>>>> main

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Ứng dụng Sức khỏe'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FeatureTile(
            title: 'Theo dõi nước uống',
            subtitle: 'Ghi nhận lượng nước và tiến độ mỗi ngày',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF0288D1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WaterTrackingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureTile(
            title: 'Theo dõi dinh dưỡng',
            subtitle: 'Quản lý calo, carb và protein theo bữa ăn',
            icon: Icons.restaurant_menu,
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionTrackingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureTile(
            title: 'Theo dõi giấc ngủ',
            subtitle: 'Ghi nhận số giờ ngủ và mục tiêu',
            icon: Icons.bedtime_outlined,
            color: const Color(0xFF3949AB),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SleepTrackingScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _FeatureTile(
            title: 'Theo dõi huyết áp',
            subtitle: 'Theo dõi chỉ số và lịch sử đo',
            icon: Icons.favorite_outline,
            color: const Color(0xFFD32F2F),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BloodPressureTrackingScreen()),
=======
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
>>>>>>> main
              );
            },
          ),
        ],
      ),
<<<<<<< HEAD
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
=======
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Lời chào
            const Text(
              'Chào mừng trở lại!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Hôm nay bạn khỏe mạnh chứ?',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 40),

            // Nút Tính BMI - Nổi bật
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calculate_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tính chỉ số BMI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kiểm tra tình trạng cân nặng của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BMICalculatorScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tính BMI ngay',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Các chức năng khác (có thể thêm sau)
            const Text(
              'Khám phá thêm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Thêm các card khác ở đây sau...
          ],
>>>>>>> main
        ),
      ),
    );
  }
}
