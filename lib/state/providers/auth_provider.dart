import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user.dart';
import '../../services/auth_service.dart';

class UserAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Khởi tạo
  UserAuthProvider() {
    _initAuthState();
    _disableRecaptcha(); // Thêm phương thức để vô hiệu hóa reCAPTCHA
  }

  // Phương thức mới để vô hiệu hóa reCAPTCHA
  Future<void> _disableRecaptcha() async {
    try {
      await firebase_auth.FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true
      );
    } catch (e) {
      print('Lỗi khi vô hiệu hóa reCAPTCHA: $e');
    }
  }

  // Lắng nghe trạng thái xác thực
  void _initAuthState() {
    _authService.authStateChanges.listen((firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      if (firebaseUser != null) {
        // Người dùng đã đăng nhập, lấy dữ liệu từ Firestore
        try {
          _user = await _authService.getUserData();
        } catch (e) {
          _error = 'Không thể lấy thông tin người dùng: $e';
        }
      } else {
        // Người dùng đã đăng xuất
        _user = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  // Đăng ký tài khoản mới - Thêm xử lý reCAPTCHA
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Đảm bảo reCAPTCHA bị vô hiệu hóa trước khi đăng ký
      await _disableRecaptcha();

      await _authService.registerWithEmailAndPassword(email, password, name);
      return true;
    } catch (e) {
      // Xử lý trường hợp lỗi reCAPTCHA cụ thể
      if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
          e.toString().contains('reCAPTCHA')) {
        try {
          await _disableRecaptcha();
          await _authService.registerWithEmailAndPassword(email, password, name);
          return true;
        } catch (retryError) {
          _error = _handleAuthError(retryError);
        }
      } else {
        _error = _handleAuthError(e);
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập bằng email và password - Thêm xử lý reCAPTCHA
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Đảm bảo reCAPTCHA bị vô hiệu hóa trước khi đăng nhập
      await _disableRecaptcha();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      // Xử lý trường hợp lỗi reCAPTCHA cụ thể
      if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
          e.toString().contains('reCAPTCHA')) {
        try {
          await _disableRecaptcha();
          await _authService.signInWithEmailAndPassword(email, password);
          return true;
        } catch (retryError) {
          _error = _handleAuthError(retryError);
        }
      } else {
        _error = _handleAuthError(e);
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập bằng Google - Thêm xử lý reCAPTCHA
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Đảm bảo reCAPTCHA bị vô hiệu hóa
      await _disableRecaptcha();

      final result = await _authService.signInWithGoogle();
      return result != null;
    } catch (e) {
      // Tương tự như trên
      if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
          e.toString().contains('reCAPTCHA')) {
        try {
          await _disableRecaptcha();
          final result = await _authService.signInWithGoogle();
          return result != null;
        } catch (retryError) {
          _error = _handleAuthError(retryError);
        }
      } else {
        _error = _handleAuthError(e);
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Các phương thức khác giữ nguyên
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (e) {
      _error = _handleAuthError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Cập nhật dữ liệu người dùng
      _user = await _authService.getUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xử lý lỗi xác thực - Thêm xử lý cho lỗi reCAPTCHA
  String _handleAuthError(dynamic e) {
    String message = 'Đã xảy ra lỗi không xác định';

    if (e.toString().contains('wrong-password') ||
        e.toString().contains('user-not-found')) {
      message = 'Email hoặc mật khẩu không đúng';
    } else if (e.toString().contains('email-already-in-use')) {
      message = 'Email đã được sử dụng bởi tài khoản khác';
    } else if (e.toString().contains('weak-password')) {
      message = 'Mật khẩu quá yếu, vui lòng chọn mật khẩu khác';
    } else if (e.toString().contains('invalid-email')) {
      message = 'Email không hợp lệ';
    } else if (e.toString().contains('too-many-requests')) {
      message = 'Quá nhiều yêu cầu không thành công. Vui lòng thử lại sau';
    } else if (e.toString().contains('network-request-failed')) {
      message = 'Lỗi kết nối mạng';
    } else if (e.toString().contains('CONFIGURATION_NOT_FOUND') ||
        e.toString().contains('reCAPTCHA')) {
      message = 'Lỗi xác thực, vui lòng thử lại sau';
    }

    return message;
  }
}