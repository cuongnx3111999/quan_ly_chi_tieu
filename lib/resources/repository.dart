import 'dart:async';
import 'package:money_grower/models/budget_model.dart';
import 'package:money_grower/models/transaction_model.dart';
import 'package:money_grower/resources/budget_provider.dart';
import 'package:money_grower/resources/transaction_provider.dart';
import 'package:money_grower/resources/user_provider.dart';
import '../models/user_model.dart';

class Repository {
  final userProvider = UserProvider();
  final transactionProvider = TransactionProvider();
  final budgetProvider = BudgetProvider();

  // User methods
  Future<UserModel?> getUserByUsername(String username) =>
      userProvider.getUserByUsername(username);

  Future<void> insertUser(UserModel data) =>
      userProvider.insertUser(data);

  Future<void> updateUser(UserModel data) =>
      userProvider.updateUser(data);

  // Transaction methods
  Future<TransactionModel?> getTransactionById(String id) async {
    final result = await transactionProvider.getTransactionById(id);
    return result;
  }

  /// TransactionSummary trả về Map chứ không phải List<TransactionModel>
  Future<Map<String, dynamic>> getTransactionSummaryOfMonth(DateTime date, String username) async {
    final result = await transactionProvider.getTransactionSummaryOfMonth(date, username);
    return result;
  }

  /// getPriceOfTransactionTypeInTime trả về int (hoặc num), không phải double
  Future<int> getPriceOfTransactionTypeInTime(
      String name, DateTime beginDate, DateTime endDate, String username) async {
    final result = await transactionProvider.getPriceOfTransactionTypeInTime(
      name, beginDate, endDate, username,
    );
    return result as int;
  }

  /// getLoanDebtList trả về Map chứ không phải List<TransactionModel>
  Future<Map<String, List<DebtTransactionModel>>> getLoanDebtList(String username) async {
    final result = await transactionProvider.getLoanDebtList(username);
    return result;
  }

  Future<void> insertTransaction(TransactionModel transaction, String username) async {
    // Truyền username vào provider
    await transactionProvider.insertTransaction(transaction, username);

    // Update user income
    final user = await userProvider.getUserByUsername(username);
    if (user != null) {
      user.income = (user.income ?? 0) - transaction.price;
      await userProvider.updateUser(user);
    } else {
      throw Exception("User '$username' not found when inserting transaction.");
    }

    // Update matched budget
    final budget = await budgetProvider.getMatchBudgetByTransaction(transaction, username);
    if (budget != null) {
      budget.totalUsed += transaction.price;
      await budgetProvider.updateBudget(budget);
    }
  }

  Future<void> deleteTransaction(TransactionModel transaction, String username) async {
    await transactionProvider.deleteTransaction(transaction.id!);

    // Update user income
    final user = await userProvider.getUserByUsername(username);
    if (user != null) {
      user.income = (user.income ?? 0) + transaction.price;
      await userProvider.updateUser(user);
    } else {
      throw Exception("User '$username' not found when deleting transaction.");
    }

    // Update matched budget
    final budget = await budgetProvider.getMatchBudgetByTransaction(transaction, username);
    if (budget != null) {
      budget.totalUsed -= transaction.price;
      await budgetProvider.updateBudget(budget);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction, String username) async {
    final oldTransaction = await transactionProvider.getTransactionById(transaction.id!);
    if (oldTransaction == null) {
      throw Exception('Old transaction not found');
    }

    // Xóa giao dịch cũ (với username)
    await deleteTransaction(oldTransaction, username);
    // Thêm giao dịch mới (với username)
    await insertTransaction(transaction, username);
  }

  // Budget methods
  Future<List<BudgetModel>> getBudgetsByUsername(String username) =>
      budgetProvider.getBudgetsByUsername(username);

  Future<void> insertBudget(BudgetModel budget) =>
      budgetProvider.insertBudget(budget);

  Future<void> deleteBudget(String id) =>
      budgetProvider.deleteBudget(id);

  Future<void> updateBudget(BudgetModel budget) =>
      budgetProvider.updateBudget(budget);

  Future<BudgetModel?> getMatchBudgetByTransaction(
      TransactionModel transaction, String username) =>
      budgetProvider.getMatchBudgetByTransaction(transaction, username);
}
