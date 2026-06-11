import 'package:flutter/material.dart';
import 'package:wellness_app/core/theme/app_colors.dart';

class UserDialogHelper {
  /// Hiển thị hộp thoại xác nhận khóa tài khoản và yêu cầu nhập lý do.
  /// Trả về chuỗi lý do nếu người dùng đồng ý khóa, trả về null nếu hủy.
  static Future<String?> showLockUserDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.gpp_bad_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            const Expanded(child: Text('Khóa tài khoản', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 20))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn khóa tài khoản này không? Người dùng sẽ không thể đăng nhập.',
              style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text('Lý do khóa (Bắt buộc):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Nhập lý do...',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600))
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do!')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Khóa tài khoản', style: TextStyle(fontWeight: FontWeight.w700))
          ),
        ],
      ),
    );

    if (confirm == true) {
      return reasonController.text.trim();
    }
    return null;
  }

  /// Hiển thị hộp thoại xác nhận mở khóa tài khoản.
  /// Trả về true nếu đồng ý, false/null nếu hủy.
  static Future<bool?> showUnlockUserDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.gpp_good_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            const Expanded(child: Text('Mở khóa tài khoản', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 20))),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn mở khóa tài khoản này không? Người dùng sẽ có thể đăng nhập lại vào hệ thống bình thường.',
          style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Mở khóa', style: TextStyle(fontWeight: FontWeight.w700))
          ),
        ],
      ),
    );
  }
}
