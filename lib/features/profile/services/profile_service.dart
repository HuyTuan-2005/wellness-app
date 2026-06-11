import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream lấy dữ liệu profile của user từ Firestore
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Hàm cập nhật profile lên Firestore (nếu cần dùng sau này)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
