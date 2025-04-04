
class Validators {
  // Kiểm tra định dạng email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // Kiểm tra mật khẩu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  // Kiểm tra xác nhận mật khẩu
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  // Kiểm tra tên
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }

    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }

    return null;
  }

  // Kiểm tra số tiền
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }

    final amountValue = double.tryParse(value.replaceAll(',', '.'));

    if (amountValue == null) {
      return 'Số tiền không hợp lệ';
    }

    if (amountValue <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }

    return null;
  }

  // Kiểm tra tên danh mục
  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên danh mục';
    }

    if (value.length < 2) {
      return 'Tên danh mục phải có ít nhất 2 ký tự';
    }

    return null;
  }
}