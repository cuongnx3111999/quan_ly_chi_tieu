import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String? id;
  final String name;
  final DateTime beginDate;
  final DateTime endDate;
  final int totalBudget;
  int totalUsed;
  final String username;

  BudgetModel({
    this.id,
    required this.name,
    required this.beginDate,
    required this.endDate,
    required this.totalBudget,
    required this.totalUsed,
    required this.username,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      name: data['name'] ?? '',
      beginDate: _toDateTime(data['beginDate']),
      endDate: _toDateTime(data['endDate']),
      totalBudget: data['totalBudget'] ?? 0,
      totalUsed: data['totalUsed'] ?? 0,
      username: data['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'beginDate': Timestamp.fromDate(beginDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalBudget': totalBudget,
      'totalUsed': totalUsed,
      'username': username,
    };
  }

  static DateTime _toDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      throw Exception('Invalid date format');
    }
  }
}
