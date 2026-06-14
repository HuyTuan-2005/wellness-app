import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/medical/medication/models/medication.dart';
import 'package:wellness_app/data/services/notification_service.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';

class MedicationController {
  // ==================== THÊM THUỐC MỚI ====================

  static Future<bool> addMedication({
    required String name,
    required String dosage,
    required TimeOfDay time,
    required String durationDaysStr,
    required String totalQuantityStr,
    required String notes,
    required String frequency,
  }) async {
    try {
      int durationDays = int.tryParse(durationDaysStr) ?? 0;
      int totalQuantity = int.tryParse(totalQuantityStr) ?? 0;
      String timeFormatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      String todayStr = DateTime.now().toIso8601String().split('T')[0];

      MedicationModel newMedication = MedicationModel(
        name: name.trim(),
        dosage: dosage.trim(),
        time: timeFormatted,
        frequency: frequency,
        durationDays: durationDays,
        totalQuantity: totalQuantity,
        takenQuantity: 0,
        notes: notes.trim(),
        status: "upcoming",
        startDate: todayStr,
        lastTakenDate: null,
        nextDoseDate: todayStr,
      );

      // Lưu xuống Database
      int id = await DatabaseHelper.instance.insertMedication(newMedication);

      // Hẹn giờ báo thức liều đầu tiên
      if (id > 0) {
        DateTime now = DateTime.now();
        DateTime firstDoseTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        // Nếu giờ nhập nhỏ hơn hiện tại → đẩy sang ngày mai
        if (firstDoseTime.isBefore(now)) {
          firstDoseTime = firstDoseTime.add(const Duration(days: 1));
        }

        await NotificationService().scheduleNotification(
          id: id,
          title: "💊 Đã đến giờ uống thuốc!",
          body:
              "Bạn có lịch uống ${newMedication.dosage} ${newMedication.name}. Nhớ uống đúng giờ nhé!",
          scheduledTime: firstDoseTime,
        );
        
        DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi khi lưu thuốc: $e");
      return false;
    }
  }

  // ==================== LOGIC TÍNH TOÁN NGHIỆP VỤ ====================

  /// Parse số liều từ chuỗi dosage (VD: "2 viên" → 2)
  static int parseDoseAmount(String dosage) {
    final match = RegExp(r'\d+').firstMatch(dosage);
    return match != null ? (int.tryParse(match.group(0)!) ?? 1) : 1;
  }

  /// Xác định trạng thái hiển thị: "upcoming" / "overdue" / "completed"
  static String calculateDisplayStatus(MedicationModel med) {
    String todayStr = DateTime.now().toIso8601String().split('T')[0];
    DateTime now = DateTime.now();

    int doseAmount = parseDoseAmount(med.dosage);
    int dosesTaken = med.takenQuantity ~/ doseAmount;

    bool isFullyCompleted =
        med.status == 'completed' || dosesTaken >= med.durationDays;
    bool isTakenToday = med.lastTakenDate == todayStr;

    if (isFullyCompleted || isTakenToday) return "completed";

    // Kiểm tra quá giờ uống
    if (!isTakenToday && med.nextDoseDate != null) {
      try {
        DateTime nextDate = DateTime.parse(med.nextDoseDate!);
        List<String> timeParts = med.time.split(':');
        DateTime medDateTime = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );
        if (now.isAfter(medDateTime)) return "overdue";
      } catch (_) {
        // Bỏ qua lỗi parse date/time không hợp lệ
      }
    }

    return "upcoming";
  }

  /// Kiểm tra cảnh báo hết thuốc, trả về {isWarning, warningMsg}
  static Map<String, dynamic> calculateWarning(MedicationModel med) {
    int doseAmount = parseDoseAmount(med.dosage);
    int maxDoses = med.totalQuantity ~/ doseAmount;
    int dosesTaken = med.takenQuantity ~/ doseAmount;
    int dosesLeft = maxDoses - dosesTaken;

    bool isFullyCompleted =
        med.status == 'completed' || dosesTaken >= med.durationDays;

    if (isFullyCompleted) return {'isWarning': false, 'warningMsg': ''};

    int dosesNeededToFinish = med.durationDays - dosesTaken;
    if (dosesLeft < dosesNeededToFinish && dosesLeft <= 1) {
      return {
        'isWarning': true,
        'warningMsg': dosesLeft == 0
            ? "Đã hết thuốc! Cần mua thêm."
            : "Chỉ còn đủ 1 lần uống!",
      };
    }

    return {'isWarning': false, 'warningMsg': ''};
  }

  /// Kiểm tra và cập nhật trạng thái hoàn thành liệu trình.
  /// Gọi sau khi load dữ liệu từ DB — thay vì kiểm tra trong build()
  static Future<void> checkAndUpdateCompletionStatus(
    List<MedicationModel> medications,
  ) async {
    bool hasChanged = false;
    for (final med in medications) {
      int doseAmount = parseDoseAmount(med.dosage);
      int dosesTaken = med.takenQuantity ~/ doseAmount;
      if (dosesTaken >= med.durationDays && med.status != 'completed') {
        med.status = 'completed';
        await DatabaseHelper.instance.updateMedication(med);
        hasChanged = true;
      }
    }
    if (hasChanged) {
      DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
    }
  }

  /// Tính ngày uống tiếp theo theo tần suất
  static String calculateNextDoseDate(String frequency) {
    DateTime now = DateTime.now();
    int daysToAdd;
    switch (frequency) {
      case 'Cách 1 ngày':
        daysToAdd = 2;
        break;
      case 'Cách 2 ngày':
        daysToAdd = 3;
        break;
      default:
        daysToAdd = 1;
    }
    return now.add(Duration(days: daysToAdd)).toIso8601String().split('T')[0];
  }

  /// Xử lý logic bấm "Uống": cập nhật model → ghi DB → đồng bộ notification
  static Future<void> markAsTaken(MedicationModel med) async {
    String todayStr = DateTime.now().toIso8601String().split('T')[0];
    int doseAmount = parseDoseAmount(med.dosage);

    // Cập nhật model in-memory
    med.takenQuantity += doseAmount;
    if (med.takenQuantity > med.totalQuantity) {
      med.takenQuantity = med.totalQuantity;
    }
    med.lastTakenDate = todayStr;
    med.nextDoseDate = calculateNextDoseDate(med.frequency);

    // Ghi xuống DB
    await DatabaseHelper.instance.updateMedication(med);

    // Hủy báo thức hôm nay
    await NotificationService().cancelNotification(med.id!);

    // Hẹn giờ liều tiếp theo (nếu chưa hoàn thành liệu trình)
    if (med.status != 'completed') {
      try {
        DateTime nextDate = DateTime.parse(med.nextDoseDate!);
        List<String> timeParts = med.time.split(':');
        DateTime nextDoseTime = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          int.tryParse(timeParts[0]) ?? 0,
          int.tryParse(timeParts[1]) ?? 0,
        );

        await NotificationService().scheduleNotification(
          id: med.id!,
          title: "💊 Đã đến giờ uống thuốc!",
          body:
              "Đến giờ uống ${med.dosage} ${med.name} rồi. Nhớ uống đúng giờ nhé!",
          scheduledTime: nextDoseTime,
        );
      } catch (_) {
        // Bỏ qua lỗi parse nếu time format không hợp lệ
      }
    }

    DataSyncService.syncLocalToCloud(); // Không cần await để UI không bị giật
  }

  /// Xóa lịch uống thuốc khỏi SQLite và Firestore
  static Future<void> deleteMedication(int id) async {
    try {
      await DatabaseHelper.instance.deleteMedication(id);
      await NotificationService().cancelNotification(id);
      DataSyncService.syncLocalToCloud();
    } catch (e) {
      debugPrint("Lỗi khi xóa thuốc: $e");
    }
  }
}
