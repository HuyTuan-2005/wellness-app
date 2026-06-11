import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import '../widgets/notification_item.dart';

/// Trang quản lý thông báo hệ thống.
/// Hiển thị danh sách thông báo đã gửi + FAB tạo thông báo mới.
class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  // ──── Mock Data ────
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Bảo trì hệ thống máy chủ',
      'content':
          'Hệ thống sẽ bảo trì từ 2h-4h sáng ngày 15/06. Mong quý khách thông cảm.',
      'date': '10:00 14/06/2026',
      'category': 'maintenance',
    },
    {
      'title': 'Mẹo giữ gìn sức khỏe mùa dịch',
      'content':
          'Hãy uống đủ nước và tập thể dục thường xuyên ít nhất 30 phút mỗi ngày nhé!',
      'date': '08:00 13/06/2026',
      'category': 'health',
    },
    {
      'title': 'Cập nhật phiên bản v2.5.0',
      'content':
          'Ứng dụng đã được nâng cấp lên phiên bản 2.5 với nhiều tính năng mới: theo dõi giấc ngủ, biểu đồ sức khỏe.',
      'date': '14:30 12/06/2026',
      'category': 'update',
    },
    {
      'title': 'Chương trình Sức khỏe cộng đồng',
      'content':
          'Tham gia thử thách đi bộ 10.000 bước/ngày trong tháng 6 để nhận phần quà hấp dẫn!',
      'date': '09:00 10/06/2026',
      'category': 'promo',
    },
    {
      'title': 'Thông báo bảo mật',
      'content':
          'Vui lòng đổi mật khẩu định kỳ để bảo vệ tài khoản. Không chia sẻ OTP cho bất kỳ ai.',
      'date': '16:00 08/06/2026',
      'category': 'general',
    },
    {
      'title': 'Nhắc nhở uống thuốc',
      'content':
          'Đã đến giờ uống thuốc buổi sáng. Hãy đảm bảo bạn uống đúng liều lượng theo đơn bác sĩ.',
      'date': '07:00 07/06/2026',
      'category': 'health',
    },
  ];

  // ──── Modal tạo thông báo mới ────
  void _showCreateNotificationModal() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạo thông báo mới',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Label: Tiêu đề
                const Text(
                  'Tiêu đề',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tiêu đề thông báo...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Label: Nội dung
                const Text(
                  'Nội dung',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập nội dung chi tiết...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nút gửi
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          contentController.text.isNotEmpty) {
                        setState(() {
                          _notifications.insert(0, {
                            'title': titleController.text,
                            'content': contentController.text,
                            'date':
                                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            'category': 'general',
                          });
                        });
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Đã gửi thông báo thành công!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Phát thông báo ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý thông báo',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_notifications.length} thông báo đã gửi',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Danh sách thông báo ────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return NotificationItem(
                    title: notif['title']!,
                    content: notif['content']!,
                    date: notif['date']!,
                    category: notif['category'] ?? 'general',
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB tạo thông báo mới
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateNotificationModal,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: AppColors.surface),
        label: const Text(
          'Tạo mới',
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
