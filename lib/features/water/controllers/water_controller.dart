import 'package:flutter/material.dart';
import '../models/water_entry.dart';

class WaterController extends ChangeNotifier {
  int _currentMl = 0;
  int _goalMl = 2000;
  final List<WaterEntry> _history = [];

  int get currentMl => _currentMl;
  int get goalMl => _goalMl;
  List<WaterEntry> get history => List.unmodifiable(_history);

  double get progress => (_currentMl / _goalMl).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
  int get glassesLeft => ((_goalMl - _currentMl) / 250).ceil().clamp(0, 999);

  bool addWater(int ml) {
    if (ml <= 0) return false;
    final wasBelowGoal = _currentMl < _goalMl;
    _currentMl += ml;
    _history.insert(0, WaterEntry(ml: ml, time: TimeOfDay.now()));
    notifyListeners();
    return wasBelowGoal && _currentMl >= _goalMl;
  }

  bool updateGoal(int goalMl) {
    if (goalMl < 500) return false;
    _goalMl = goalMl;
    notifyListeners();
    return true;
  }
}
