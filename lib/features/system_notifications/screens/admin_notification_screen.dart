import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wellness_app/core/theme/app_colors.dart';
import '../widgets/notification_item.dart';
import 'create_notification_screen.dart';
import '../services/notification_service.dart';

/// Trang quản lý thông báo hệ thống dành cho Admin.
class AdminNotificationScreen extends StatelessWidget {
  AdminNotificationScreen({super.key});

  final NotificationService _notificationService = NotificationService();

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
                  StreamBuilder<QuerySnapshot>(
                    stream: _notificationService.getNotificationsCountStream(),
                    builder: (context, snapshot) {
                      int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return Text(
                        '$count thông báo đã gửi',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),

            // ─── Danh sách thông báo ────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notificationService.getNotificationsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 64,
                            color: AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có thông báo nào được tạo.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      String dateStr = '';
                      final createdAt = data['createdAt'] as Timestamp?;
                      if (createdAt != null) {
                        dateStr = DateFormat('HH:mm dd/MM/yyyy').format(createdAt.toDate());
                      }

                      return NotificationItem(
                        title: data['title'] ?? 'Thông báo',
                        content: data['content'] ?? '',
                        date: dateStr,
                        category: data['category'] ?? 'general',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB tạo thông báo mới
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotificationScreen(),
            ),
          );
        },
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

