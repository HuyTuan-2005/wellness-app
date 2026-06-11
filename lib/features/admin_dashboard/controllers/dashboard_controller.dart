import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController {
  /// Tính toán các chỉ số người dùng từ dữ liệu Firebase
  /// Trả về Map chứa: totalUsers, todayActive, weeklyActive, activeRate
  static Map<String, int> calculateUserStats(List<QueryDocumentSnapshot> docs) {
    int totalUsers = docs.length;
    int todayActive = 0;
    int weeklyActive = 0;
    int activeRate = 0;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lastActiveTs = data['lastActive'] as Timestamp?;
      if (lastActiveTs != null) {
        final lastActiveDate = lastActiveTs.toDate();
        if (lastActiveDate.isAfter(todayStart)) {
          todayActive++;
        }
        if (lastActiveDate.isAfter(weekStart)) {
          weeklyActive++;
        }
      }
    }

    if (totalUsers > 0) {
      activeRate = ((weeklyActive / totalUsers) * 100).round();
    }

    return {
      'totalUsers': totalUsers,
      'todayActive': todayActive,
      'weeklyActive': weeklyActive,
      'activeRate': activeRate,
    };
  }
}
