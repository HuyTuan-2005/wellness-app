import 'package:flutter/material.dart';
import 'package:wellness_app/features/BMI/screens/BMI_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/features/profile/screens/profile_screen.dart';

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
        ),
      ),
    );
  }
}
