import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_grower/models/user_model.dart';

class CurrentUser {
  static UserModel? user;

  static void setUser(UserModel u) {
    user = u;
  }

  static String? get username => user?.username;

  static String? get id => user?.id;

  static void clear() {
    user = null;
  }

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isLoggedIn {
    final user = _auth.currentUser;
    return user != null && user.email != null && user.email!.isNotEmpty;
  }

  static String? get email => _auth.currentUser?.email;

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}


