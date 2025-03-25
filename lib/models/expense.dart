import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id; // null khi chưa lưu vào Firestore
  final double amount; // Số tiền chi tiêu
  final DateTime date; // Ngày chi tiêu
  final String categoryId; // ID của danh mục
  final String? note; // Ghi chú về khoản chi
  final String userId; // ID của người dùng tạo khoản chi
  final String? imageUrl; // Đường dẫn ảnh hóa đơn (nếu có)
  final String? location; // Địa điểm chi tiêu (nếu có)
  final bool isRecurring; // Khoản chi định kỳ hay không
  final String? recurringType; // Loại định kỳ (hàng ngày, hàng tuần, hàng tháng...)
  final DateTime createdAt; // Thời gian tạo bản ghi

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
    required this.userId,
    this.imageUrl,
    this.location,
    this.isRecurring = false,
    this.recurringType,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Expense(
      id: doc.id,
      amount: (data['amount'] is int)
          ? (data['amount'] as int).toDouble()
          : data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      categoryId: data['categoryId'] ?? '',
      note: data['note'],
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'],
      location: data['location'],
      isRecurring: data['isRecurring'] ?? false,
      recurringType: data['recurringType'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'note': note,
      'userId': userId,
      'imageUrl': imageUrl,
      'location': location,
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Expense copyWith({
    double? amount,
    DateTime? date,
    String? categoryId,
    String? note,
    String? imageUrl,
    String? location,
    bool? isRecurring,
    String? recurringType,
  }) {
    return Expense(
      id: this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      userId: this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      createdAt: this.createdAt,
    );
  }
}