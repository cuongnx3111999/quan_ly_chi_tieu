import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String name;
  final String note;
  final DateTime date;
  final int price;
  final String username;

  TransactionModel({
    this.id,
    required this.name,
    required this.note,
    required this.price,
    required this.date,
    required this.username,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> snapshot, String id) {
    return TransactionModel(
      id: id,
      name: snapshot['name'] ?? '',
      note: snapshot['note'] ?? '',
      price: (snapshot['price'] is num) ? (snapshot['price'] as num).toInt() : 0,
      date: _toDateTime(snapshot['date']),
      username: snapshot['username'] ?? '',
    );
  }

  /// Phải truyền username khi gọi toJson để đảm bảo đúng dữ liệu
  Map<String, dynamic> toJson({required String username}) {
    return {
      "date": Timestamp.fromDate(date),
      "date-month": date.month,
      "date-year": date.year,
      "username": username,
      "name": name,
      "note": note,
      "price": price,
    };
  }

  static DateTime _toDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      throw Exception('Invalid date format');
    }
  }
}

class DebtTransactionModel extends TransactionModel {
  bool done;

  DebtTransactionModel({
    String? id,
    required String name,
    required String note,
    required int price,
    required DateTime date,
    required String username,
    this.done = false,
  }) : super(
    id: id,
    name: name,
    note: note,
    price: price,
    date: date,
    username: username,
  );

  factory DebtTransactionModel.fromMap(Map<String, dynamic> snapshot, String id) {
    return DebtTransactionModel(
      id: id,
      name: snapshot['name'] ?? '',
      note: snapshot['note'] ?? '',
      price: (snapshot['price'] is num) ? (snapshot['price'] as num).toInt() : 0,
      date: TransactionModel._toDateTime(snapshot['date']),
      username: snapshot['username'] ?? '',
      done: snapshot['done'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson({required String username}) {
    final json = super.toJson(username: username);
    json['done'] = done;
    return json;
  }
}
