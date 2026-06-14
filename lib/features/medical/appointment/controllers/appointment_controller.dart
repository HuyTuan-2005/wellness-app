import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';
import 'package:wellness_app/data/services/notification_service.dart';
import 'package:wellness_app/features/medical/appointment/models/appointment.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentController {
  // ==================== THÊM LỊCH KHÁM MỚI ====================

  static Future<bool> addAppointment({
    required String doctorName,
    required String location,
    required String dateTime, // Định dạng ISO8601
    required int reminderOffset,
    required String notes,
  }) async {
    try {
      AppointmentModel newAppointment = AppointmentModel(
        doctorName: doctorName.trim(),
        location: location.trim(),
        dateTime: dateTime,
        reminderOffset: reminderOffset,
        notes: notes.trim(),
        status: "upcoming",
      );

      // Lưu xuống Database
      int id = await DatabaseHelper.instance.insertAppointment(newAppointment);

      // Hẹn giờ báo thức
      if (id > 0) {

        DateTime scheduledTime = DateTime.parse(dateTime);
        DateTime notificationTime = scheduledTime.subtract(
          Duration(minutes: reminderOffset),
        );
        DateTime now = DateTime.now();

        // Chỉ đặt thông báo nếu thời gian báo thức vẫn ở trong tương lai
        if (notificationTime.isAfter(now)) {
          // Lấy id + 10000 để tách biệt với ID thông báo của Thuốc
          int notificationId = id + 10000;

          await NotificationService().scheduleNotification(
            id: notificationId,
            title: "🏥 Nhắc nhở lịch khám sắp tới!",
            body:
                "Bạn có lịch hẹn với $doctorName tại $location vào lúc ${formatDateTime(dateTime)}.",
            scheduledTime: notificationTime,
          );
        }

        DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi khi lưu lịch hẹn: $e");
      return false;
    }
  }

  // ==================== LOGIC TÍNH TOÁN NGHIỆP VỤ ====================

  /// Xác định trạng thái hiển thị: "upcoming" / "overdue" / "completed"
  static String calculateDisplayStatus(AppointmentModel appointment) {
    if (appointment.status == 'completed') return "completed";

    try {
      DateTime appointmentTime = DateTime.parse(appointment.dateTime);
      DateTime now = DateTime.now();

      if (now.isAfter(appointmentTime)) {
        return "overdue";
      }
      return "upcoming";
    } catch (e) {
      // Nếu lỗi parse, mặc định trả về upcoming hoặc status gốc
      return appointment.status;
    }
  }

  /// Đánh dấu đã khám xong
  static Future<void> markAsCompleted(AppointmentModel appointment) async {
    try {
      appointment.status = 'completed';

      // Ghi xuống DB
      await DatabaseHelper.instance.updateAppointment(appointment);

      // Hủy báo thức nếu vẫn chưa kêu
      int notificationId = (int.tryParse(appointment.id!) ?? 0) + 10000;
      await NotificationService().cancelNotification(notificationId);

      DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
    } catch (e) {
      debugPrint("Lỗi khi đánh dấu hoàn thành lịch khám: $e");
    }
  }

  /// Xóa lịch khám
  static Future<void> deleteAppointment(AppointmentModel appointment) async {
    try {
      if (appointment.id != null) {
        int id = int.tryParse(appointment.id!) ?? 0;
        // Xóa khỏi DB
        if (id > 0) {
          await DatabaseHelper.instance.deleteAppointment(id);
        }

        // Hủy báo thức
        int notificationId = id + 10000;
        await NotificationService().cancelNotification(notificationId);

        DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
      }
    } catch (e) {
      debugPrint("Lỗi khi xóa lịch khám: $e");
    }
  }

  /// Hàm tiện ích: Chuyển đổi DateTime chuẩn ISO sang chuỗi hiển thị
  static String formatDateTime(String isoDateTime) {
    try {
      DateTime dt = DateTime.parse(isoDateTime);
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();

      return "$hour:$minute - $day/$month/$year";
    } catch (e) {
      return isoDateTime; // Nếu lỗi trả về chuỗi gốc
    }
  }

  // ==================== CHỈ ĐƯỜNG ====================

  /// Mở ứng dụng bản đồ dẫn đường đến phòng khám
  static Future<void> mapsToClinic(String location) async {
    try {
      if (location.trim().isEmpty) {
        debugPrint("Địa chỉ phòng khám trống.");
        return;
      }

      final String encodedLocation = Uri.encodeComponent(location);
      final Uri mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Không thể mở bản đồ với địa chỉ: $location");
      }
    } catch (e) {
      debugPrint("Lỗi khi mở bản đồ: $e");
    }
  }
}
