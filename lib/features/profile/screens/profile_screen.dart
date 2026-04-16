import 'package:flutter/material.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/features/register_login/screens/login_screen.dart';
import 'edit_profile_screen.dart'; // ← Import này rất quan trọng

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Thông tin
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: const Icon(
                      Icons.person,
                      size: 65,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UserProfile.userName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    UserProfile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ).then((_) => setState(() {})); // Refresh sau khi quay về
                    },
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text('Chỉnh sửa thông tin'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _buildSectionTitle('Thông tin cơ bản'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow('Giới tính', UserProfile.gender),
              _buildInfoRow('Tuổi', '${UserProfile.age} tuổi'),
              _buildInfoRow(
                'Chiều cao',
                '${UserProfile.height.toStringAsFixed(1)} cm',
              ),
              _buildInfoRow(
                'Cân nặng',
                '${UserProfile.weight.toStringAsFixed(1)} kg',
              ),
              _buildInfoRow('Nhóm máu', UserProfile.bloodType),
            ]),

            const SizedBox(height: 24),

            _buildSectionTitle('Mục tiêu sức khỏe'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow(
                'Mục tiêu cân nặng',
                '${UserProfile.targetWeight.toStringAsFixed(1)} kg',
              ),
              _buildInfoRow(
                'Lượng nước mỗi ngày',
                '${(UserProfile.dailyWaterGoal / 1000).toStringAsFixed(1)} lít',
              ),
              _buildInfoRow('Mục tiêu vận động', UserProfile.exerciseGoal),
            ]),

            const SizedBox(height: 24),

            _buildSectionTitle('Thông tin sức khỏe khác'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildInfoRow('Dị ứng', UserProfile.allergies),
              _buildInfoRow('Bệnh lý nền', 'Không khai báo'),
            ]),

            const SizedBox(height: 40),

            _buildSectionTitle('Quản lý'),
            const SizedBox(height: 8),
            _buildMenuItem(Icons.history_rounded, 'Lịch sử hoạt động', () {}),
            _buildMenuItem(Icons.settings_rounded, 'Cài đặt', () {}),
            _buildMenuItem(Icons.logout_rounded, 'Đăng xuất', () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGET HỖ TRỢ ====================
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  Widget _buildInfoCard(List<Widget> children) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: AppColors.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: children),
    ),
  );

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    leading: Icon(
      icon,
      color: isDestructive ? Colors.red : const Color.fromARGB(255, 69, 69, 69),
      size: 26,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w500,
        color: isDestructive ? Colors.red : AppColors.textPrimary,
      ),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    onTap: onTap,
  );
}
