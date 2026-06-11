import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách users (không phải admin) dưới dạng Stream
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots();
  }
}
