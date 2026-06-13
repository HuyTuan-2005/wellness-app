import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:wellness_app/core/utils/app_helpers.dart';
import 'package:wellness_app/core/widgets/auth_widgets.dart';
import 'package:wellness_app/data/services/auth_service.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';
import 'package:wellness_app/features/register_login/screens/forgotpassword_screen.dart';
import 'package:wellness_app/features/register_login/screens/register_screen.dart';

import 'package:wellness_app/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Xử lý đăng nhập bằng Google
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (userCredential != null && userCredential.user != null) {
        // Kiểm tra xem tài khoản có bị khóa không
        final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          final bool isLocked = userData['isLocked'] ?? false;
          
          if (isLocked) {
            final String? reason = userData['lockReason'] as String?;
            await _authService.signOut();
            setState(() => _isGoogleLoading = false);
            
            // Hiển thị thông báo
            _showLockedDialog(reason);
            return;
          }
        }

        if (!mounted) return;

        // Đăng nhập thành công → AuthWrapper sẽ điều hướng
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
      // userCredential == null nghĩa là user đã huỷ, không cần xử lý gì
    } catch (e) {
      if (!mounted) return;
      AppHelpers.showSnackBar(context, 'Đăng nhập Google thất bại: $e');
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showLockedDialog(String? reason) {
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
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          reason != null && reason.isNotEmpty 
            ? 'Tài khoản của bạn đã bị khóa với lý do:\n"$reason"\n\nVui lòng liên hệ quản trị viên để biết thêm chi tiết.'
            : 'Tài khoản của bạn đã bị Admin khóa. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.',
          style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / Icon
                const SizedBox(height: 32),

                // Tiêu đề
                Text(
                  'Đăng nhập tài khoản',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'để tiếp tục hành trình sức khỏe',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                AuthWidgets.buildLabel('Email'),
                const SizedBox(height: 8),
                AuthWidgets.buildTextField(
                  controller: _emailController,
                  hint: 'Nhập email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mật khẩu
                AuthWidgets.buildLabel('Mật khẩu'),
                const SizedBox(height: 8),
                AuthWidgets.buildTextField(
                  controller: _passwordController,
                  hint: 'Nhập mật khẩu',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu tối thiểu 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        AppHelpers.showLoading(context);
                        final credential = await _authService
                            .signInWithEmailAndPassword(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                        if (context.mounted) {
                          AppHelpers.hideLoading(context);
                          if (credential != null && credential.user != null) {
                            // Kiểm tra xem tài khoản có bị khóa không
                            final doc = await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).get();
                            if (doc.exists) {
                              final userData = doc.data() as Map<String, dynamic>;
                              final bool isLocked = userData['isLocked'] ?? false;
                              
                              if (isLocked) {
                                final String? reason = userData['lockReason'] as String?;
                                await _authService.signOut();
                                if (!context.mounted) return;
                                AppHelpers.hideLoading(context);
                                _showLockedDialog(reason);
                                return;
                              }
                            }

                            if (!context.mounted) return;

                            // AuthWrapper sẽ tự động xử lý chuyển hướng
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthWrapper(),
                              ),
                              (route) => false,
                            );
                          } else {
                            AppHelpers.showErrorSnackBar(
                              context,
                              'Đăng nhập thất bại. Vui lòng kiểm tra lại email/mật khẩu.',
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.secondary)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'hoặc',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 24),

                // Nút Đăng nhập bằng Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGoogleLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/google-icon-logo.svg",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Đăng nhập bằng Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // Chưa có tài khoản
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
