import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/resources/repository.dart';

class TransactionBloc {
  final repository = Repository();

  Future<int> getPriceOfTransactionTypeInTime(
      String name, DateTime beginDate, DateTime endDate, String username) =>
      repository.getPriceOfTransactionTypeInTime(
          name, beginDate, endDate, username);

  Future<Map<String, dynamic>> getTransactionSummaryOfMonth(DateTime date, String username) =>
      repository.getTransactionSummaryOfMonth(date, username);

  Future<Map<String, List<DebtTransactionModel>>> getLoanDebtList(String username) =>
      repository.getLoanDebtList(username);

  Future<void> insertTransaction(TransactionModel transaction, String username) =>
      repository.insertTransaction(transaction, username);

  Future<void> updateTransaction(TransactionModel transaction, String username) =>
      repository.updateTransaction(transaction, username);

  Future<void> deleteTransaction(TransactionModel transaction, String username) =>
      repository.deleteTransaction(transaction, username);
}
