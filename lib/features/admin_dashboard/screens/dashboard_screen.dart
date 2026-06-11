import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/admin_dashboard/screens/dashboard_content_page.dart';
import 'package:wellness_app/features/system_notifications/screens/admin_notification_screen.dart';
import 'package:wellness_app/features/user_management/screens/user_list_screen.dart';

/// Màn hình chính Admin – khung nền chứa BottomNavigationBar.
/// Sử dụng IndexedStack để giữ trạng thái các trang khi chuyển tab.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // ── 3 trang con được giữ trong IndexedStack (đã xóa Lịch hẹn) ──
  final List<Widget> _pages = const [
    DashboardContentPage(),       // Tab 0: Tổng quan
    UserListScreen(),             // Tab 1: Người dùng
    AdminNotificationScreen(),    // Tab 2: Thông báo
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giữ trạng thái tất cả trang – không reload khi chuyển tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.dashboard_rounded),
              ),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.people_alt_rounded),
              ),
              label: 'Người dùng',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.notifications_rounded),
              ),
              label: 'Thông báo',
            ),
          ],
        ),
      ),
    );
  }
}
