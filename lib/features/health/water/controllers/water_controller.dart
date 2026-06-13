import 'package:flutter/material.dart';
import 'package:wellness_app/core/database/database_helper.dart';
import 'package:wellness_app/data/services/data_sync_service.dart';
import 'package:wellness_app/features/profile/utils/data_helper.dart';
import '../models/water_entry.dart';

class WaterController extends ChangeNotifier {
  // Singleton pattern
  static final WaterController _instance = WaterController._internal();
  factory WaterController() => _instance;

  int _currentMl = 0;
  List<WaterEntry> _history = [];
  String? _dateStr;

  WaterController._internal() {
    _loadRecordsForToday();
  }

  String _getTodayDateStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadRecordsForToday() async {
    final today = _getTodayDateStr();
    _dateStr = today;

    _history = await DatabaseHelper.instance.getWaterEntriesForDate(today);
    
    _currentMl = _history.fold(0, (sum, entry) => sum + entry.ml);
    
    notifyListeners();
  }

  void _checkRollover() {
    if (_dateStr != _getTodayDateStr()) {
      _loadRecordsForToday();
    }
  }

  int get currentMl {
    _checkRollover();
    return _currentMl;
  }

  int get goalMl => UserProfile.dailyWaterGoal;
  
  List<WaterEntry> get history {
    _checkRollover();
    return List.unmodifiable(_history);
  }

  double get progress => (currentMl / goalMl).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  int get glassesLeft => ((goalMl - currentMl) / 250).ceil().clamp(0, 999);

  bool addWater(int ml) {
    if (ml <= 0) return false;
    _checkRollover();

    final wasBelowGoal = _currentMl < goalMl;
    _currentMl += ml;
    
    WaterEntry entry = WaterEntry(
      ml: ml,
      date: DateTime.now().toIso8601String(),
    );
    
    _history.insert(0, entry);
    notifyListeners();

    // Lưu vào SQLite và đồng bộ ngầm
    DatabaseHelper.instance.insertWaterEntry(entry).then((id) {
      if (id > 0) {
        entry.id = id;
        DataSyncService.syncLocalToCloud();
      }
    });

    return wasBelowGoal && _currentMl >= goalMl;
  }

  bool updateGoal(int goalMl) {
    if (goalMl < 500) return false;
    UserProfile.dailyWaterGoal = goalMl;
    notifyListeners();
    // Do thiết kế ban đầu lưu UserProfile thông qua SharedPrefs, 
    // ta giữ nguyên hoặc bỏ qua việc gọi trực tiếp Firestore ở đây.
    return true;
  }

  void removeEntry(int index) {
    _checkRollover();
    if (index < 0 || index >= _history.length) return;

    final entry = _history[index];
    if (entry.id != null) {
      DatabaseHelper.instance.deleteWaterEntry(entry.id!).then((result) {
        if (result > 0) {
          DataSyncService.syncLocalToCloud();
        }
      });
    }
    
    _currentMl -= entry.ml;
    if (_currentMl < 0) _currentMl = 0;
    _history.removeAt(index);
    notifyListeners();
  }

  // Hàm thủ công gọi khi có thay đổi từ Cloud Sync kéo về
  Future<void> reloadData() async {
    await _loadRecordsForToday();
  }
}
