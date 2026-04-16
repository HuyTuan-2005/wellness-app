import 'package:flutter/material.dart';
import 'package:wellness_app/features/blood_pressure/screens/blood_pressure_tracking_screen.dart';
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
      appBar: AppBar(title: const Text('Ứng dụng Sức khỏe'), centerTitle: true),
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
                MaterialPageRoute(
                  builder: (_) => const NutritionTrackingScreen(),
                ),
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
                MaterialPageRoute(
                  builder: (_) => const BloodPressureTrackingScreen(),
                ),
              );
            },
          ),
        ],
      ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
