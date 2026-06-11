import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy tổng số lượng thông báo dưới dạng Stream
  Stream<QuerySnapshot> getNotificationsCountStream() {
    return _firestore.collection('notifications').snapshots();
  }

  /// Lấy danh sách các thông báo dưới dạng Stream, sắp xếp theo thời gian mới nhất
  Stream<QuerySnapshot> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Tạo một thông báo mới
  Future<void> createNotification({
    required String title,
    required String content,
    required String category,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'content': content,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
