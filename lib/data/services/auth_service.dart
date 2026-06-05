import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy user hiện tại (nếu đã đăng nhập)
  User? get currentUser => _auth.currentUser;

  /// Stream theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng nhập bằng Google (google_sign_in v7.x)
  ///
  /// Flow:
  /// 1. Khởi tạo GoogleSignIn instance
  /// 2. Mở Google Sign-In popup bằng authenticate()
  /// 3. Xác thực với Firebase Auth bằng idToken
  /// 4. Kiểm tra user trong Firestore → tạo mới hoặc cập nhật lastActive
  ///
  /// Trả về [UserCredential] nếu thành công, [null] nếu lỗi.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Bước 1: Mở Google Sign-In flow (initialize đã gọi trong main.dart)
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // Bước 3: Lấy idToken từ authentication (sync getter trong v7.x)
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Bước 4: Đăng nhập vào Firebase Auth
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        print('[AuthService] Không lấy được thông tin user từ Firebase Auth.');
        return null;
      }

      // Bước 5: Kiểm tra & đồng bộ user trong Firestore
      await _syncUserToFirestore(user);

      print('[AuthService] Đăng nhập thành công: ${user.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('[AuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('[AuthService] Lỗi không xác định khi đăng nhập Google: $e');
      return null;
    }
  }

  /// Kiểm tra user trong Firestore và tạo mới hoặc cập nhật
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final DocumentReference userDoc =
          _firestore.collection('users').doc(user.uid);

      final DocumentSnapshot snapshot = await userDoc.get();

      if (!snapshot.exists) {
        // Lần đầu đăng nhập → Tạo document mới
        await userDoc.set({
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'role': 'user',
          'isLocked': false,
          'fcmToken': '',
          'lastActive': FieldValue.serverTimestamp(),
        });
        print('[AuthService] Đã tạo user mới trong Firestore: ${user.uid}');
      } else {
        // Đã tồn tại → Chỉ cập nhật lastActive
        await userDoc.set({
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('[AuthService] Đã cập nhật lastActive cho user: ${user.uid}');
      }
    } catch (e) {
      print('[AuthService] Lỗi khi đồng bộ user vào Firestore: $e');
    }
  }

  /// Đăng xuất khỏi cả Google và Firebase
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
      print('[AuthService] Đã đăng xuất thành công.');
    } catch (e) {
      print('[AuthService] Lỗi khi đăng xuất: $e');
    }
  }
}
