import 'package:flutter/material.dart';
import 'package:wellness_app/data/services/auth_service.dart';
import 'package:wellness_app/features/home/screens/main_navigation_screen.dart';
import 'package:wellness_app/features/register_login/screens/forgotpassword_screen.dart';
import 'package:wellness_app/features/register_login/screens/register_screen.dart';
import 'package:wellness_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:wellness_app/core/widgets/auth_widgets.dart';
import '../../../core/theme/app_colors.dart';
import 'package:wellness_app/core/utils/app_helpers.dart';

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

      if (userCredential != null) {
        // Đăng nhập thành công → điều hướng về HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
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

  /// Widget hiển thị logo Google "G" bằng CustomPaint
  Widget _buildGoogleLogo() {
    return SizedBox(
      height: 22,
      width: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
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
                        final credential = await _authService.signInWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (context.mounted) {
                          AppHelpers.hideLoading(context);
                          if (credential != null && credential.user != null) {
                            // Thành công, kiểm tra role
                            final role = await _authService.getUserRole(credential.user!.uid);
                            if (context.mounted) {
                              if (role == 'admin') {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                                  (route) => false,
                                );
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          } else {
                            AppHelpers.showErrorSnackBar(context, 'Đăng nhập thất bại. Vui lòng kiểm tra lại email/mật khẩu.');
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
                              _buildGoogleLogo(),
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

/// CustomPainter vẽ logo Google "G" với 4 màu đặc trưng
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;
    final double strokeWidth = w * 0.2;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Xanh dương (trên phải) - 0° đến -90° (tức 270° đến 360°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2),
      -0.52, // ~-30°
      -1.57, // ~-90°
      false,
      paint,
    );

    // Xanh lá (dưới phải)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2),
      1.57, // ~90°
      -1.05, // ~-60°
      false,
      paint,
    );

    // Vàng (dưới trái)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2),
      1.57, // ~90°
      1.05, // ~60°
      false,
      paint,
    );

    // Đỏ (trên trái)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2),
      2.62, // ~150°
      1.05, // ~60°
      false,
      paint,
    );

    // Thanh ngang của chữ G (màu xanh dương)
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - strokeWidth / 2, r * 0.5, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
