import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String? id;
  final double amount; // Số tiền ngân sách
  final DateTime startDate; // Ngày bắt đầu
  final DateTime endDate; // Ngày kết thúc
  final String categoryId; // ID danh mục (null nếu áp dụng cho tất cả)
  final String userId; // ID người dùng
  final String name; // Tên ngân sách
  final String
  period; // Kỳ ngân sách: 'daily', 'weekly', 'monthly', 'yearly', 'custom'
  final bool isRecurring; // Ngân sách lặp lại theo kỳ hay không
  final DateTime createdAt; // Thời gian tạo

  Budget({
    this.id,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
    required this.userId,
    required this.name,
    required this.period,
    this.isRecurring = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Budget(
      id: doc.id,
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : data['amount'] ?? 0.0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      categoryId: data['categoryId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      period: data['period'] ?? 'monthly',
      isRecurring: data['isRecurring'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'categoryId': categoryId,
      'userId': userId,
      'name': name,
      'period': period,
      'isRecurring': isRecurring,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Budget copyWith({
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? name,
    String? period,
    bool? isRecurring,
  }) {
    return Budget(
      id: id,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
      userId: userId,
      name: name ?? this.name,
      period: period ?? this.period,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt,
    );
  }

  // Tạo ngân sách mới cho kỳ tiếp theo (nếu là ngân sách lặp lại)
  Budget createNextPeriodBudget() {
    if (!isRecurring) return this;

    DateTime newStartDate;
    DateTime newEndDate;

    // Tính toán kỳ tiếp theo dựa vào loại kỳ
    switch (period) {
      case 'daily':
        newStartDate = endDate.add(Duration(days: 1));
        newEndDate = newStartDate.add(Duration(days: 1));
        break;
      case 'weekly':
        newStartDate = endDate.add(Duration(days: 1));
        newEndDate = newStartDate.add(Duration(days: 7));
        break;
      case 'monthly':
        // Thêm một tháng vào ngày kết thúc
        newStartDate = DateTime(endDate.year, endDate.month + 1, 1);
        // Tính ngày cuối tháng
        final nextMonth =
            endDate.month + 2 > 12
                ? DateTime(endDate.year + 1, (endDate.month + 2) % 12, 1)
                : DateTime(endDate.year, endDate.month + 2, 1);
        newEndDate = nextMonth.subtract(Duration(days: 1));
        break;
      case 'yearly':
        newStartDate = DateTime(endDate.year + 1, 1, 1);
        newEndDate = DateTime(endDate.year + 1, 12, 31);
        break;
      default: // custom period
        final duration = endDate.difference(startDate);
        newStartDate = endDate.add(Duration(days: 1));
        newEndDate = newStartDate.add(duration);
    }

    return Budget(
      amount: amount,
      startDate: newStartDate,
      endDate: newEndDate,
      categoryId: categoryId,
      userId: userId,
      name: name,
      period: period,
      isRecurring: isRecurring,
    );
  }
}
