import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/data/services/auth_service.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';
import 'package:wellness_app/features/device/screens/device_screen.dart';
import 'package:wellness_app/features/system_notifications/screens/user_notification_screen.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Chưa đăng nhập'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _profileService.getUserProfileStream(currentUser!.uid),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            // Cập nhật UserProfile tĩnh để các màn hình khác không bị lỗi
            UserProfile.updateProfileFromMap(data);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Avatar & Thông tin
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: currentUser?.photoURL != null
                              ? NetworkImage(currentUser!.photoURL!)
                              : null,
                          child: currentUser?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 45,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserProfile.userName.isNotEmpty
                                  ? UserProfile.userName
                                  : 'Người dùng',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UserProfile.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard([
                        _buildMenuItem(
                          Icons.person_outline_rounded,
                          'Thông tin cá nhân',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(Icons.watch_outlined, 'Thiết bị', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeviceScreen(),
                            ),
                          );
                        }),
                        _buildMenuItem(
                          Icons.notifications_none_rounded,
                          'Thông báo',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserNotificationScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          Icons.info_outline_rounded,
                          'Giới thiệu',
                          () {},
                        ),
                        _buildMenuItem(
                          Icons.logout_rounded,
                          'Đăng xuất',
                          () async {
                            // Bước 1: Kiểm tra xem có dữ liệu Offline chưa đồng bộ không
                            bool hasUnsynced = await DatabaseHelper.instance.hasUnsyncedData();

                            if (hasUnsynced) {
                              if (!context.mounted) return;
                              // Bước 2: Hiện Dialog cảnh báo màu đỏ
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Cảnh báo mất dữ liệu', style: TextStyle(color: Colors.red)),
                                  content: const Text(
                                    'CẢNH BÁO: Bạn có dữ liệu chưa được đồng bộ lên đám mây (do mất mạng hoặc đang chờ). '
                                    'Nếu đăng xuất bây giờ, dữ liệu này sẽ bị MẤT VĨNH VIỄN do dữ liệu cục bộ sẽ bị xóa để bảo vệ tài khoản.\n\n'
                                    'Bạn có chắc chắn muốn tiếp tục đăng xuất không?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Vẫn Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) {
                                return; // Ngừng tiến trình đăng xuất
                              }
                            }

                            // Bước 3: Đã đồng bộ hết, HOẶC người dùng chấp nhận mất dữ liệu
                            // Quét sạch dữ liệu của người dùng cũ trên thiết bị
                            await DatabaseHelper.instance.clearAllLocalData();
                            
                            // Tiến hành đăng xuất Auth
                            await AuthService().signOut();

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AuthWrapper(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          isDestructive: true,
                        ),
                      ]),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGET HỖ TRỢ ====================
  Widget _buildInfoCard(List<Widget> children) {
    List<Widget> separatedChildren = [];
    for (int i = 0; i < children.length; i++) {
      separatedChildren.add(children[i]);
      if (i < children.length - 1) {
        separatedChildren.add(
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(children: separatedChildren),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDestructive
            ? Colors.red.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
        size: 22,
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDestructive ? Colors.red : AppColors.textPrimary,
      ),
    ),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: Colors.grey,
      size: 20,
    ),
    onTap: onTap,
  );
}
