import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_grower/blocs/user_bloc.dart';
import 'package:money_grower/helper/current_user.dart';
import 'package:money_grower/models/user_model.dart';
import 'package:money_grower/ui/custom_control/faded_transition.dart';
import 'package:money_grower/ui/main_screen/main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final UserBloc _userBloc = UserBloc();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _authUser(LoginData data) async {
    try {
      final existingUser = await _userBloc.getUserByUsername(data.name);
      if (existingUser == null) {
        return "Email chưa được đăng ký";
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        return "Vui lòng xác thực email trước khi đăng nhập";
      }

      // Đăng nhập thành công, lưu user vào CurrentUser
      CurrentUser.setUser(existingUser);

      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      return "Lỗi hệ thống: ${e.toString()}";
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      final existingUser = await _userBloc.getUserByUsername(data.name!);
      if (existingUser != null) {
        return "Email đã được đăng ký!";
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      // Tạo UserModel mới và lưu vào Firestore
      final newUser = UserModel(
        id: "", // Hoặc lấy id từ userCredential.user?.uid nếu cần
        username: data.name!,
        income: 0,
      );
      await _userBloc.insertUser(newUser);

      // Lưu user mới vào CurrentUser
      CurrentUser.setUser(newUser);

      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      return "Lỗi hệ thống: ${e.toString()}";
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      final existingUser = await _userBloc.getUserByUsername(email);
      if (existingUser == null) {
        return "Email chưa được đăng ký";
      }

      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseAuthErrorMessage(e);
    } catch (e) {
      return "Lỗi hệ thống: ${e.toString()}";
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'operation-not-allowed':
        return 'Thao tác không được cho phép';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      default:
        return 'Lỗi đăng nhập: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: FlutterLogin(
          title: 'MoneyGrower',
          logo: 'assets/coins.png',
          theme: LoginTheme(
            primaryColor: Colors.green,
            accentColor: Colors.white,
            errorColor: Colors.red,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            bodyStyle: const TextStyle(color: Colors.black),
            textFieldStyle: const TextStyle(color: Colors.white),
            buttonStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          messages: LoginMessages(
            userHint: 'Email',
            passwordHint: 'Mật khẩu',
            confirmPasswordHint: "Nhập lại mật khẩu",
            confirmPasswordError: "Mật khẩu không khớp",
            loginButton: 'Đăng nhập',
            signupButton: 'Đăng ký',
            recoverPasswordButton: 'Khôi phục mật khẩu',
            recoverPasswordIntro: 'Nhập email để nhận liên kết khôi phục mật khẩu',
            recoverPasswordDescription:
            'Chúng tôi sẽ gửi email hướng dẫn đặt lại mật khẩu',
            recoverPasswordSuccess: 'Email khôi phục đã được gửi!',
            goBackButton: 'Quay lại',
            forgotPasswordButton: 'Quên mật khẩu?',
          ),
          onLogin: (loginData) => _authUser(loginData),
          onSignup: (signupData) => _signupUser(signupData),
          onRecoverPassword: _recoverPassword,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(
              FadeRoute(page: MainScreen()),
            );
          },
          hideForgotPasswordButton: false,
          loginAfterSignUp: false,
        ),
      ),
    );
  }
}