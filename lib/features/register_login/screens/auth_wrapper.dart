import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/data/services/auth_service.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import 'package:wellness_app/features/admin/screens/dashboard_screen.dart';
import 'package:wellness_app/features/home/screens/main_navigation_screen.dart';
import 'package:wellness_app/features/register_login/screens/login_screen.dart';
import 'package:wellness_app/features/register_login/screens/onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isShowingLockedDialog = false;
  String? _lastSyncedUid;

  @override
  void initState() {
    super.initState();
    // Đăng ký observer để lắng nghe sự kiện vòng đời của ứng dụng
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Hủy đăng ký observer khi widget bị hủy
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Khi ứng dụng được mở lại từ background
    if (state == AppLifecycleState.resumed) {
      _authService.updateUserActivity();
    }
  }

  /// Hàm xử lý khi tài khoản bị khóa
  void _handleLockedUser(String? reason) async {
    if (_isShowingLockedDialog) return;
    _isShowingLockedDialog = true;

    // Ép đăng xuất
    await AuthService().signOut();

    if (!mounted) return;

    // Hiển thị dialog thông báo
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tài khoản bị khóa',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          reason != null && reason.isNotEmpty
              ? 'Tài khoản của bạn đã bị khóa với lý do:\n"$reason"\n\nVui lòng liên hệ quản trị viên để biết thêm chi tiết.'
              : 'Tài khoản của bạn đã bị Admin khóa. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _isShowingLockedDialog = false;
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isShowingLockedDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái đăng nhập của Firebase Auth
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // Nếu chưa đăng nhập, chuyển đến màn hình Login
        if (user == null) {
          return const LoginScreen();
        }

        // Lắng nghe dữ liệu của user trong Firestore theo realtime
        return StreamBuilder<DocumentSnapshot>(
          stream: _authService.getUserStream(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasData &&
                userSnapshot.data != null &&
                userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;
              final bool isLocked = userData?['isLocked'] ?? false;
              final String? lockReason = userData?['lockReason'] as String?;
              final String role = userData?['role'] ?? 'user';

              if (userData != null) {
                // Cập nhật thông tin UserProfile thời gian thực
                UserProfile.updateProfileFromMap(userData);
              }

              // Chỉ chạy đồng bộ khi vừa đăng nhập thành công và tài khoản không bị khóa
              if (!isLocked && _lastSyncedUid != user.uid) {
                _lastSyncedUid = user.uid;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  DataSyncService().syncOnLogin(user.uid);
                });
              }

              // Nếu bị khóa, gọi hàm ép đăng xuất sau khi frame hiện tại vẽ xong
              if (isLocked) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleLockedUser(lockReason);
                });
                // Trả về màn hình chờ trong lúc đăng xuất
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (role == 'admin') {
                return const DashboardScreen();
              }

              // Kiểm tra xem UserProfile đã có dữ liệu cơ bản chưa (cân nặng, chiều cao)
              // Nếu chưa có (== 0.0), hiển thị màn hình Onboarding
              if (role == 'user' && (UserProfile.height == 0.0 || UserProfile.weight == 0.0 || UserProfile.age == 0)) {
                return const OnboardingScreen();
              }
            } else {
              // Trường hợp fallback nếu user không có document trên Firestore
              if (UserProfile.height == 0.0 || UserProfile.weight == 0.0 || UserProfile.age == 0) {
                return const OnboardingScreen();
              }
            }

            // Nếu mọi thứ ổn, hiển thị màn hình chính cho user
            return const MainNavigationScreen();
          },
        );
      },
    );
  }
}
