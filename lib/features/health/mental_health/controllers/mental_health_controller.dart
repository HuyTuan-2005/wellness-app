import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/features/health/mental_health/models/mental_health.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';

class MentalHealthController extends ChangeNotifier {
  List<MentalHealthRecord> _records = [];
  final Map<DateTime, List<MentalHealthRecord>> _eventsMap = {};
  bool _isLoading = false;

  List<MentalHealthRecord> get records => _records;
  bool get isLoading => _isLoading;

  MentalHealthController() {
    loadRecords();
  }

  // Chuẩn hóa ngày (bỏ giờ phút) để dùng làm Key cho Map
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await DatabaseHelper.instance.getAllMentalHealthRecords();

    _eventsMap.clear();
    for (var record in _records) {
      try {
        DateTime dt = DateTime.parse(record.dateTime);
        DateTime normalized = _normalizeDate(dt);
        if (_eventsMap[normalized] == null) {
          _eventsMap[normalized] = [];
        }
        _eventsMap[normalized]!.add(record);
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

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
        
        // Cập nhật Events Map cho TableCalendar
        DateTime normalized = _normalizeDate(date);
        if (_eventsMap[normalized] == null) {
          _eventsMap[normalized] = [];
        }
        _eventsMap[normalized]!.insert(0, newRecord);

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

  // Lấy các record trong một ngày cụ thể - Cực kỳ mượt vì dùng Map (O(1))
  List<MentalHealthRecord> getRecordsForDay(DateTime day) {
    DateTime normalized = _normalizeDate(day);
    return _eventsMap[normalized] ?? [];
  }
}
