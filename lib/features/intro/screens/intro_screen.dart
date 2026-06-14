import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/register_login/screens/auth_wrapper.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _introData = [
    {
      "title": "Wellness App",
      "description": "Trợ lý chăm sóc sức khỏe toàn diện của bạn. Giúp bạn theo dõi và cải thiện lối sống mỗi ngày.",
      "icon": Icons.health_and_safety_rounded,
      "color": Colors.teal,
    },
    {
      "title": "Theo dõi Offline-First",
      "description": "Ghi chép lượng nước uống, thời gian ngủ, huyết áp và cân nặng mọi lúc, mọi nơi, ngay cả khi không có mạng Internet.",
      "icon": Icons.signal_wifi_off_rounded,
      "color": Colors.blue,
    },
    {
      "title": "Trợ lý AI Gemini",
      "description": "Nhận lời khuyên dinh dưỡng và sức khỏe được cá nhân hóa hoàn toàn nhờ công nghệ AI tiên tiến.",
      "icon": Icons.psychology_rounded,
      "color": Colors.purple,
    },
    {
      "title": "Nhắc nhở Tự động",
      "description": "Hệ thống báo thức sẽ giúp bạn không bao giờ quên giờ uống thuốc hay lỡ hẹn khám bệnh.",
      "icon": Icons.edit_notifications_rounded,
      "color": Colors.orange,
    }
  ];

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Nút Bỏ qua
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _onIntroEnd(context),
                child: const Text(
                  "Bỏ qua",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ),
            ),
            
            // Slider nội dung
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _introData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: (_introData[index]["color"] as Color).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _introData[index]["icon"] as IconData,
                            size: 100,
                            color: _introData[index]["color"] as Color,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          _introData[index]["title"] as String,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _introData[index]["description"] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator & Nút Next/Done
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dấu chấm (Dots Indicator)
                  Row(
                    children: List.generate(
                      _introData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),

                  // Nút chuyển trang / Hoàn tất
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _introData.length - 1) {
                        _onIntroEnd(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentPage == _introData.length - 1 ? "Bắt đầu ngay" : "Tiếp theo",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
