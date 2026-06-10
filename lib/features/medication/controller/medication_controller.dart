import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/medication/models/medication.dart';

class MedicationController {
  // Hàm xử lý logic thêm lịch uống thuốc
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
      // 1. Chuyển đổi dữ liệu từ dạng Chuỗi (String) sang Số Nguyên (Int)
      int durationDays = int.parse(durationDaysStr);
      int totalQuantity = int.parse(totalQuantityStr);

      // 2. Định dạng thời gian thành chuẩn chuỗi 24h (ví dụ: "08:30" hoặc "14:05")
      String timeFormatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      // Lấy ngày hôm nay theo chuẩn "YYYY-MM-DD"
      String todayStr = DateTime.now().toIso8601String().split('T')[0];

      // 3. Đóng gói dữ liệu vào Model
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
        startDate: todayStr, // Bắt đầu từ hôm nay
        lastTakenDate: null, // Chưa uống lần nào
        nextDoseDate: todayStr, // Cần uống ngay hôm nay
      );

      // 4. Gọi Database để thực thi lệnh Insert xuống SQLite
      int id = await DatabaseHelper.instance.insertMedication(newMedication);

      // Nếu id > 0 nghĩa là SQLite đã lưu thành công và cấp ID cho bản ghi
      return id > 0;
    } catch (e) {
      // Bắt lỗi trong trường hợp người dùng nhập chữ vào ô số khiến hàm int.parse bị crash
      debugPrint("Lỗi khi lưu thuốc: $e");
      return false;
    }
  }
}

