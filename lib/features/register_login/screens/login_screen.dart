import 'package:flutter/material.dart';
import 'package:wellness_app/features/home/screens/home_screen.dart';
import 'package:wellness_app/features/register_login/screens/forgotpassword_screen.dart';
import 'package:wellness_app/features/register_login/screens/register_screen.dart';
import 'package:wellness_app/features/register_login/widgets/widget.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                const SizedBox(height: 24),

                // Logo / Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tiêu đề
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập để tiếp tục hành trình sức khỏe',
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
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      //   // TODO: Xử lý đăng nhập
                      // }

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false, // Xóa hết màn hình trước đó
                      );
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
