import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/admin_dashboard/widgets/report_card.dart';
import 'package:wellness_app/features/admin_dashboard/widgets/weekly_bar_chart.dart';
import 'package:wellness_app/features/admin_dashboard/controllers/dashboard_controller.dart';
import 'package:wellness_app/features/home/screens/main_navigation_screen.dart';

/// Trang nội dung Dashboard – hiển thị thẻ báo cáo số liệu và biểu đồ.
/// Đây là nội dung bên trong tab "Tổng quan".
class DashboardContentPage extends StatelessWidget {
  DashboardContentPage({super.key});

  final DashboardService _dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng quan hệ thống',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút chuyển giao diện User
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        tooltip: 'Chuyển sang giao diện người dùng',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Report Cards ──────────────
                StreamBuilder<QuerySnapshot>(
                  stream: _dashboardService.getUsersStream(),
                  builder: (context, userSnapshot) {
                    int totalUsers = 0;
                    int todayActive = 0;
                    int activeRate = 0;

                    if (userSnapshot.hasData) {
                      final docs = userSnapshot.data!.docs;
                      final stats = DashboardController.calculateUserStats(docs);
                      
                      totalUsers = stats['totalUsers']!;
                      todayActive = stats['todayActive']!;
                      activeRate = stats['activeRate']!;
                    }

                    return Column(
                      children: [
                        // Hàng 1
                        Row(
                          children: [
                            Expanded(
                              child: ReportCard(
                                icon: Icons.people_alt_rounded,
                                value: totalUsers.toString(),
                                label: 'Tổng người dùng',
                                accentColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ReportCard(
                                icon: Icons.directions_run_rounded,
                                value: todayActive.toString(),
                                label: 'Truy cập hôm nay',
                                accentColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Hàng 2
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _dashboardService
                                    .getNotificationsCountStream(),
                                builder: (context, notifSnapshot) {
                                  int totalNotifs = 0;
                                  if (notifSnapshot.hasData) {
                                    totalNotifs =
                                        notifSnapshot.data!.docs.length;
                                  }
                                  return ReportCard(
                                    icon: Icons.notifications_active_rounded,
                                    value: totalNotifs.toString(),
                                    label: 'Thông báo đã phát',
                                    accentColor: AppColors.warning,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ReportCard(
                                icon: Icons.trending_up_rounded,
                                value: '$activeRate%',
                                label: 'Tỉ lệ hoạt động',
                                accentColor: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ─── Chart Section ──────────────────
                const WeeklyBarChart(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
