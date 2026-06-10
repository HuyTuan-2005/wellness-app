import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/medication/models/medication.dart';
import 'package:wellness_app/service/notification_service.dart';

class MedicationController {
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
      int durationDays = int.parse(durationDaysStr);
      int totalQuantity = int.parse(totalQuantityStr);
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

      // --- LOGIC MỚI: HẸN GIỜ BÁO THỨC LIỀU ĐẦU TIÊN ---
      if (id > 0) {
        DateTime now = DateTime.now();
        DateTime firstDoseTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        // Nếu giờ nhập vào nhỏ hơn giờ hiện tại (VD: Bây giờ là 14h, nhập 08h sáng)
        // thì đẩy báo thức sang 08h sáng ngày mai
        if (firstDoseTime.isBefore(now)) {
          firstDoseTime = firstDoseTime.add(const Duration(days: 1));
        }

        // Gọi dịch vụ hẹn giờ
        await NotificationService().scheduleNotification(
          id: id, // Dùng chính ID của SQLite làm ID báo thức để dễ quản lý
          title: "💊 Đã đến giờ uống thuốc!",
          body:
              "Bạn có lịch uống ${newMedication.dosage} ${newMedication.name}. Nhớ uống đúng giờ nhé!",
          scheduledTime: firstDoseTime,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi khi lưu thuốc: $e");
      return false;
    }
  }
}

