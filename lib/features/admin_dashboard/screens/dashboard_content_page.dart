import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import 'package:wellness_app/features/admin_dashboard/widgets/report_card.dart';
import 'package:wellness_app/features/admin_dashboard/widgets/weekly_bar_chart.dart';

/// Trang nội dung Dashboard – hiển thị thẻ báo cáo số liệu và biểu đồ.
/// Đây là nội dung bên trong tab "Tổng quan".
class DashboardContentPage extends StatelessWidget {
  const DashboardContentPage({super.key});

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
                            'Xin chào, Admin 👋',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
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
                    // Avatar admin
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Report Cards – 2 hàng x 2 cột ──────────────
                // Hàng 1
                Row(
                  children: [
                    Expanded(
                      child: ReportCard(
                        icon: Icons.people_alt_rounded,
                        value: '1,250',
                        label: 'Tổng người dùng',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ReportCard(
                        icon: Icons.directions_run_rounded,
                        value: '342',
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
                      child: ReportCard(
                        icon: Icons.notifications_active_rounded,
                        value: '15',
                        label: 'Thông báo đã phát',
                        accentColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ReportCard(
                        icon: Icons.trending_up_rounded,
                        value: '89%',
                        label: 'Tỉ lệ hoạt động',
                        accentColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Chart Section ──────────────────
                const WeeklyBarChart(),
                const SizedBox(height: 24),

                // ─── Recent Activity ────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hoạt động gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityItem(
                        icon: Icons.person_add_rounded,
                        color: AppColors.primary,
                        title: 'Người dùng mới đăng ký',
                        subtitle: 'Nguyễn Văn An vừa tạo tài khoản',
                        time: '5 phút trước',
                      ),
                      _buildDivider(),
                      _buildActivityItem(
                        icon: Icons.security_rounded,
                        color: AppColors.success,
                        title: 'Đăng nhập bảo mật',
                        subtitle: 'Phát hiện đăng nhập mới từ IP 192.168.1.5',
                        time: '15 phút trước',
                      ),
                      _buildDivider(),
                      _buildActivityItem(
                        icon: Icons.campaign_rounded,
                        color: AppColors.warning,
                        title: 'Thông báo hệ thống đã gửi',
                        subtitle: 'Bảo trì máy chủ lúc 02:00 AM',
                        time: '1 giờ trước',
                      ),
                      _buildDivider(),
                      _buildActivityItem(
                        icon: Icons.block_rounded,
                        color: AppColors.error,
                        title: 'Tài khoản bị khóa',
                        subtitle: 'user_spam_01@mail.com vi phạm chính sách',
                        time: '3 giờ trước',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon hoạt động
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Thời gian
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.border,
      height: 1,
    );
  }
}
