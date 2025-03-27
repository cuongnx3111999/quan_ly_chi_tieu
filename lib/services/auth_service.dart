import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream trả về trạng thái đăng nhập hiện tại
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Đăng ký bằng email và mật khẩu
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Tạo tài khoản trên Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo document user trong Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!.uid, name, email);
      }

      return credential;
    } catch (e) {
      rethrow; // Đẩy lỗi lên để xử lý ở UI
    }
  }

  // Đăng nhập bằng email và mật khẩu
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Khởi chạy luồng đăng nhập của Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Lấy thông tin xác thực từ request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase bằng credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Kiểm tra và tạo document user trong Firestore nếu chưa có
      if (userCredential.user != null) {
        await _checkAndCreateUserDocument(
          userCredential.user!.uid,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.email ?? '',
          userCredential.user!.photoURL,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Đăng xuất Google (nếu có)
      await _auth.signOut(); // Đăng xuất Firebase
    } catch (e) {
      rethrow;
    }
  }

  // Khôi phục mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật thông tin cá nhân
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        await _auth.currentUser!.updatePhotoURL(photoURL);

        // Cập nhật thông tin trong Firestore
        if (displayName != null || photoURL != null) {
          final userRef = _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid);

          Map<String, dynamic> updateData = {};
          if (displayName != null) updateData['name'] = displayName;
          if (photoURL != null) updateData['photoUrl'] = photoURL;

          await userRef.update(updateData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy thông tin user model từ Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (_auth.currentUser == null) return null;

      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Tạo document user trong Firestore
  Future<void> _createUserDocument(
    String uid,
    String name,
    String email, [
    String? photoUrl,
  ]) async {
    final userModel = UserModel(
      id: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      currency: 'VND',
      settings: {'darkMode': false, 'notificationsEnabled': true},
    );

    await _firestore.collection('users').doc(uid).set(userModel.toMap());
  }

  // Kiểm tra và tạo document user nếu chưa tồn tại
  Future<void> _checkAndCreateUserDocument(
    String uid,
    String name,
    String email, [
    String? photoUrl,
  ]) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();

    if (!docSnapshot.exists) {
      await _createUserDocument(uid, name, email, photoUrl);
    }
  }
}
