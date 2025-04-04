import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/auth_text_field.dart';
import '../../widgets/common/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quên mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent
                ? _buildSuccessMessage()
                : _buildRequestForm(authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm(UserAuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon và tiêu đề
          Icon(
            Icons.lock_reset,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'Khôi phục mật khẩu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhập địa chỉ email của bạn để nhận hướng dẫn đặt lại mật khẩu',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
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
          SizedBox(height: 32),

          // Nút gửi
          AuthButton(
            text: 'Gửi yêu cầu',
            onPressed: _submitForm,
            isLoading: authProvider.isLoading,
          ),
          SizedBox(height: 24),

          // Quay lại đăng nhập
          TextButton(
            onPressed: _navigateBack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 16),
                SizedBox(width: 8),
                Text('Quay lại đăng nhập'),
              ],
            ),
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
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon và tiêu đề
        Icon(
          Icons.mark_email_read,
          size: 80,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        Text(
          'Email đã được gửi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Chúng tôi đã gửi hướng dẫn đặt lại mật khẩu đến email ${_emailController.text}.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Vui lòng kiểm tra hộp thư của bạn và làm theo hướng dẫn.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        AuthButton(
          text: 'Quay lại đăng nhập',
          onPressed: _navigateBack,
          backgroundColor: Colors.green,
        ),
      ],
    );
  }
}