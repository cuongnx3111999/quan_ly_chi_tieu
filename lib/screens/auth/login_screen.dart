import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/auth_text_field.dart';
import '../../widgets/common/auth_button.dart';
import '../../widgets/common/auth_divider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Điều hướng đến màn hình chính nếu đăng nhập thành công
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Điều hướng đến màn hình chính nếu đăng nhập thành công
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(RegisterScreen.routeName);
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo và tiêu đề
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Quản Lý Chi Tiêu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Đăng nhập vào tài khoản của bạn',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Trường nhập liệu email
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Nhập địa chỉ email của bạn',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  SizedBox(height: 16),

                  // Trường nhập liệu mật khẩu
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    hint: 'Nhập mật khẩu của bạn',
                    obscureText: !_passwordVisible,
                    validator: Validators.validatePassword,
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8),

                  // Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: Text('Quên mật khẩu?'),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Nút đăng nhập
                  AuthButton(
                    text: 'Đăng nhập',
                    onPressed: _submitForm,
                    isLoading: authProvider.isLoading,
                  ),
                  SizedBox(height: 24),

                  // Hoặc đăng nhập với
                  AuthDivider(text: 'Hoặc đăng nhập với'),
                  SizedBox(height: 24),

                  // Đăng nhập với Google
                  AuthButton(
                    text: 'Đăng nhập với Google',
                    onPressed: _signInWithGoogle,
                    isLoading: false,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    icon: Icons.g_mobiledata,
                  ),
                  SizedBox(height: 32),

                  // Chưa có tài khoản? Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Hiển thị lỗi nếu có
                  if (authProvider.error != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}