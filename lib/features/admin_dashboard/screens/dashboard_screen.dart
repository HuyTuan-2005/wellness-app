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

      // ─── Bottom Navigation Bar ────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  label: 'Tổng quan',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.people_alt_rounded,
                  label: 'Người dùng',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.notifications_rounded,
                  label: 'Thông báo',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng từng item trong bottom nav với hiệu ứng active/inactive
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
