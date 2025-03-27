import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Thiết lập người dùng hiện tại
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // Đặt thuộc tính người dùng
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Ghi lại sự kiện đăng nhập
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Ghi lại sự kiện đăng ký
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Ghi lại sự kiện thêm chi tiêu
  Future<void> logAddExpense(double amount, String category) async {
    await _analytics.logEvent(
      name: 'add_expense',
      parameters: {'amount': amount, 'category': category},
    );
  }

  // Ghi lại sự kiện thêm ngân sách
  Future<void> logAddBudget(
    double amount,
    String category,
    String period,
  ) async {
    await _analytics.logEvent(
      name: 'add_budget',
      parameters: {'amount': amount, 'category': category, 'period': period},
    );
  }

  // Ghi lại sự kiện xem báo cáo
  Future<void> logViewReport(String reportType, String timePeriod) async {
    await _analytics.logEvent(
      name: 'view_report',
      parameters: {'report_type': reportType, 'time_period': timePeriod},
    );
  }

  // Ghi lại bất kỳ sự kiện tùy chỉnh nào
  Future<void> logCustomEvent(
    String name,
    Map<String, dynamic> parameters,
  ) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
