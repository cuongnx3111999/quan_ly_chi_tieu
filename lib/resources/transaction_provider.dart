import 'dart:async';
import 'package:money_grower/helper/doc_helper.dart';
import 'package:money_grower/models/transaction_model.dart';

class TransactionProvider {
  final doc = DocHelper('transactions');

  Future getTransactionSummaryOfMonth(DateTime date, String username) async {
    int totalIncome = 0;
    int totalExpense = 0;
    List<TransactionModel> transactionList = [];

    final response = await doc.ref
        .where('username', isEqualTo: username)
        .where('date-year', isEqualTo: date.year)
        .where('date-month', isEqualTo: date.month)
        .get();

    for (final docSnapshot in response.docs) {
      final data = docSnapshot.data();
      if (data == null) continue;

      final Map<String, dynamic> mapData = data as Map<String, dynamic>;

      transactionList.add(TransactionModel.fromMap(mapData, docSnapshot.id));

      final dynamic price = mapData['price'];
      if (price == null) continue;

      if (price is int) {
        if (price > 0) {
          totalIncome += price;
        } else {
          totalExpense -= price;
        }
      } else if (price is double) {
        final intPrice = price.toInt();
        if (intPrice > 0) {
          totalIncome += intPrice;
        } else {
          totalExpense -= intPrice;
        }
      } else {
        print('Invalid price type: ${price.runtimeType}');
      }
    }

    transactionList.sort((a, b) => a.name.compareTo(b.name));

    return {
      'total-income': totalIncome,
      'total-expense': totalExpense,
      'total-transaction': totalIncome - totalExpense,
      'transaction-list': transactionList,
      'date': date
    };
  }

  Future getPriceOfTransactionTypeInTime(
      String name, DateTime beginDate, DateTime endDate, String username) async {
    final response = await doc.ref
        .where('username', isEqualTo: username)
        .where('name', isEqualTo: name)
        .where('date', isGreaterThanOrEqualTo: beginDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    if (response.docs.isEmpty) return 0;

    final totalPrice = response.docs
        .map((doc) {
      final data = doc.data();
      if (data == null) return 0;
      final Map<String, dynamic> mapData = data as Map<String, dynamic>;
      final dynamic price = mapData['price'];
      if (price is int) return price;
      if (price is double) return price.toInt();
      return 0;
    })
        .reduce((a, b) => a + b);

    return totalPrice.abs();
  }

  Future getLoanDebtList(String username) async {
    List<DebtTransactionModel> loanList = [];
    List<DebtTransactionModel> debtList = [];

    final response = await doc.ref
        .where('username', isEqualTo: username)
        .where('done', isEqualTo: false)
        .get();

    for (final docSnapshot in response.docs) {
      final data = docSnapshot.data();
      if (data == null) continue;

      final Map<String, dynamic> mapData = data as Map<String, dynamic>;
      final transaction = DebtTransactionModel.fromMap(mapData, docSnapshot.id);
      if (transaction.name == 'Cho vay') {
        loanList.add(transaction);
      } else {
        debtList.add(transaction);
      }
    }

    loanList.sort((a, b) => b.date.compareTo(a.date));
    debtList.sort((a, b) => b.date.compareTo(a.date));

    return {'loan-list': loanList, 'debt-list': debtList};
  }

  /// Thêm tham số username để truyền khi gọi toJson
  Future insertTransaction(TransactionModel transaction, String username) async {
    await doc.ref.add(transaction.toJson(username: username));
  }

  Future deleteTransaction(String id) async {
    await doc.ref.doc(id).delete();
  }

  /// Thêm tham số username để truyền khi gọi toJson
  Future updateTransaction(TransactionModel transaction, String username) async {
    if (transaction.id == null) throw Exception('Transaction id is null');
    await doc.ref.doc(transaction.id).update(transaction.toJson(username: username));
  }

  Future getTransactionById(String id) async {
    final output = await doc.ref.doc(id).get();
    final data = output.data();
    if (data == null) return null;

    final Map<String, dynamic> mapData = data as Map<String, dynamic>;
    return TransactionModel.fromMap(mapData, output.id);
  }
}
