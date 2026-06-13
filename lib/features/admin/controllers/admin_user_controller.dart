import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/features/admin/services/admin_user_service.dart';
import 'package:wellness_app/features/admin/utils/user_dialog_helper.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class AdminUserController {
  /// Lọc danh sách người dùng theo từ khóa (tên hoặc email)
  static List<QueryDocumentSnapshot> filterUsersBySearchQuery(
      List<QueryDocumentSnapshot> docs, String query) {
    if (query.isEmpty) return docs;
    final lowercaseQuery = query.toLowerCase();

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['displayName'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();
  }

  /// Xử lý logic khóa/mở khóa tài khoản (bao gồm hiển thị hộp thoại xác nhận)
  static Future<void> handleToggleLockStatus({
    required BuildContext context,
    required String uid,
    required bool currentStatus,
    required AdminUserService userService,
  }) async {
    String? lockReason;

    if (!currentStatus) {
      final reason = await UserDialogHelper.showLockUserDialog(context);
      if (reason == null) return; // Người dùng hủy
      lockReason = reason;
    } else {
      final confirmUnlock = await UserDialogHelper.showUnlockUserDialog(context);
      if (confirmUnlock != true) return; // Người dùng hủy
    }

    try {
      await userService.toggleLockStatus(uid, currentStatus, reason: lockReason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!currentStatus ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'),
            backgroundColor: !currentStatus ? AppColors.error : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

