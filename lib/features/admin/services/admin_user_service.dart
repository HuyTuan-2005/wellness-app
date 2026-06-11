import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserService {
  final FirebaseFirestore _firestore;

  AdminUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách users (không phải admin) dưới dạng Stream
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots();
  }

  /// Cập nhật trạng thái khóa tài khoản
  Future<void> toggleLockStatus(String uid, bool currentStatus, {String? reason}) async {
    final updateData = <String, dynamic>{
      'isLocked': !currentStatus,
    };
    if (!currentStatus && reason != null) {
      updateData['lockReason'] = reason;
    } else if (currentStatus) {
      // Nếu đang mở khóa thì xóa lý do
      updateData['lockReason'] = FieldValue.delete();
    }

    await _firestore.collection('users').doc(uid).update(updateData);
  }
  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
