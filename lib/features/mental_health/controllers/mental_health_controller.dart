import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/mental_health/models/mental_health.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';

class MentalHealthController extends ChangeNotifier {
  List<MentalHealthRecord> _records = [];
  bool _isLoading = false;

  List<MentalHealthRecord> get records => _records;
  bool get isLoading => _isLoading;

  MentalHealthController() {
    loadRecords();
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await DatabaseHelper.instance.getAllMentalHealthRecords();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addRecord({
    required String emotion,
    required String notes,
    required DateTime date,
  }) async {
    try {
      String dateTime = date.toIso8601String();
      MentalHealthRecord newRecord = MentalHealthRecord(
        emotion: emotion,
        notes: notes,
        dateTime: dateTime,
      );

      int id = await DatabaseHelper.instance.insertMentalHealthRecord(newRecord);
      
      if (id > 0) {
        newRecord.id = id;
        // Chèn vào đầu danh sách (vì list load theo DESC)
        _records.insert(0, newRecord);
        notifyListeners();
        
        // Bắn trigger đẩy dữ liệu lên Cloud
        DataSyncService.syncLocalToCloud();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Lỗi khi lưu cảm xúc: $e");
      return false;
    }
  }

  // Lấy các record trong một ngày cụ thể
  List<MentalHealthRecord> getRecordsForDay(DateTime day) {
    return _records.where((record) {
      DateTime dt = DateTime.parse(record.dateTime);
      return dt.year == day.year && dt.month == day.month && dt.day == day.day;
    }).toList();
  }
}
