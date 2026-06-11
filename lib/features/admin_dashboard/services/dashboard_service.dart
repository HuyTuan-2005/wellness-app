import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore;

  DashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách users (không phải admin) dưới dạng Stream
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots();
  }

  /// Lấy tổng số lượng thông báo đã phát dưới dạng Stream
  Stream<QuerySnapshot> getNotificationsCountStream() {
    return _firestore.collection('notifications').snapshots();
  }
}
