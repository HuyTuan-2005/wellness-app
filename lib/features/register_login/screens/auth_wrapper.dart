import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/data/services/auth_service.dart';
import 'package:wellness_app/features/home/screens/home_screen.dart';
import 'package:wellness_app/features/register_login/screens/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isShowingLockedDialog = false;

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
      updateUserActivity();
    }
  }

  /// Hàm cập nhật thời gian hoạt động cuối cùng của user
  Future<void> updateUserActivity() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
        debugPrint('[AuthWrapper] Đã cập nhật lastActive cho user ${user.uid}');
      } catch (e) {
        debugPrint('[AuthWrapper] Lỗi khi cập nhật lastActive: $e');
      }
    }
  }

  /// Hàm xử lý khi tài khoản bị khóa
  void _handleLockedUser() async {
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
        title: const Text(
          'Tài khoản bị khóa',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tài khoản của bạn đã bị Admin khóa. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isShowingLockedDialog = false;
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
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
      stream: _auth.authStateChanges(),
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
          stream: _firestore.collection('users').doc(user.uid).snapshots(),
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

              // Nếu bị khóa, gọi hàm ép đăng xuất sau khi frame hiện tại vẽ xong
              if (isLocked) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleLockedUser();
                });
                // Trả về màn hình chờ trong lúc đăng xuất
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            }

            // Nếu mọi thứ ổn, hiển thị màn hình chính
            return const HomeScreen();
          },
        );
      },
    );
  }
}
