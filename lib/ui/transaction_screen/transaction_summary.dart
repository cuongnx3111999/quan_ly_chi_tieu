import 'package:flutter/material.dart';

class TransactionSummary {
  int totalIncome = 0;
  int totalExpense = 0;
  int totalTransaction = 0;
  List<dynamic> transactionList = [];
  DateTime date = DateTime.now();

  // Thêm thuộc tính remaining để tính số tiền còn lại
  int remaining = 0;

  static final TransactionSummary _instance = TransactionSummary._internal();
  TransactionSummary._internal();

  factory TransactionSummary() {
    return _instance;
  }

  void fromMap(Map<String, dynamic> snapshot) {
    totalIncome = snapshot['total-income'] ?? 0;
    totalExpense = snapshot['total-expense'] ?? 0;
    totalTransaction = snapshot['total-transaction'] ?? 0;
    transactionList = List<dynamic>.from(snapshot['transaction-list'] ?? []);

    // Tính toán remaining sau khi có dữ liệu
    calculateRemaining();

    final dynamic dateValue = snapshot['date'];
    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue is String) {
      date = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      try {
        // Xử lý Timestamp từ Firebase Firestore
        date = dateValue.toDate();
      } catch (e) {
        date = DateTime.now();
      }
    }
  }

  // Thêm method tính toán remaining
  void calculateRemaining() {
    remaining = totalIncome + totalExpense; // totalExpense đã âm nên cộng
  }

  // Thêm method để reset dữ liệu
  void reset() {
    totalIncome = 0;
    totalExpense = 0;
    totalTransaction = 0;
    remaining = 0;
    transactionList.clear();
    date = DateTime.now();
  }

  // Thêm method để convert sang Map (hữu ích cho việc lưu trữ)
  Map<String, dynamic> toMap() {
    return {
      'total-income': totalIncome,
      'total-expense': totalExpense,
      'total-transaction': totalTransaction,
      'transaction-list': transactionList,
      'date': date.toIso8601String(),
      'remaining': remaining,
    };
  }

  // Thêm method để validate dữ liệu
  bool isValid() {
    return transactionList.isNotEmpty &&
        totalTransaction > 0 &&
        date != null;
  }

  // Thêm method để lấy danh sách giao dịch theo loại
  List<dynamic> getIncomeTransactions() {
    return transactionList.where((transaction) {
      if (transaction is Map<String, dynamic>) {
        final price = transaction['price'] ?? 0;
        return price > 0;
      }
      return false;
    }).toList();
  }

  List<dynamic> getExpenseTransactions() {
    return transactionList.where((transaction) {
      if (transaction is Map<String, dynamic>) {
        final price = transaction['price'] ?? 0;
        return price < 0;
      }
      return false;
    }).toList();
  }

  // Thêm method để format hiển thị
  String getFormattedRemaining() {
    return "${remaining.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )} đ";
  }

  String getFormattedTotalIncome() {
    return "${totalIncome.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )} đ";
  }

  String getFormattedTotalExpense() {
    return "${totalExpense.abs().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )} đ";
  }

  // Thêm method để kiểm tra tình trạng tài chính
  String getFinancialStatus() {
    if (remaining > 0) {
      return "Thặng dư";
    } else if (remaining < 0) {
      return "Thâm hụt";
    } else {
      return "Cân bằng";
    }
  }

  Color getStatusColor() {
    if (remaining > 0) {
      return Colors.green;
    } else if (remaining < 0) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  // Override toString để debug dễ dàng
  @override
  String toString() {
    return 'TransactionSummary{totalIncome: $totalIncome, totalExpense: $totalExpense, remaining: $remaining, totalTransaction: $totalTransaction, date: $date}';
  }
}
