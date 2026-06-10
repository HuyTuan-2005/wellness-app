import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class MentalHealthTrackingScreen extends StatelessWidget {
  const MentalHealthTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sức khỏe Tinh thần',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement, size: 80, color: Colors.purple),
            ),
            const SizedBox(height: 20),
            Text(
              'Trạng thái hiện tại',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bình thường',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement stress tracking logic
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ghi nhận cảm xúc', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
