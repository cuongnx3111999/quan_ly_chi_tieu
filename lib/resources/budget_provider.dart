import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_grower/models/budget_model.dart';
import 'package:money_grower/models/transaction_model.dart';

class BudgetProvider {
  final CollectionReference ref = FirebaseFirestore.instance.collection('budgets');

  Future<List<BudgetModel>> getBudgetsByUsername(String username) async {
    var budgets = <BudgetModel>[];
    final response = await ref.where('username', isEqualTo: username).get();

    for (var doc in response.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        budgets.add(BudgetModel.fromMap(data, doc.id));
      }
    }
    return budgets;
  }

  Future<void> insertBudget(BudgetModel budget) async {
    await ref.add(budget.toJson());
  }

  Future<void> deleteBudget(String id) async {
    await ref.doc(id).delete();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await ref.doc(budget.id).update(budget.toJson());
  }

  Future<BudgetModel?> getBudgetByName(String name, String username) async {
    final response = await ref
        .where('username', isEqualTo: username)
        .where('name', isEqualTo: name)
        .get();

    if (response.docs.isEmpty) return null;

    final doc = response.docs[0];
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return BudgetModel.fromMap(data, doc.id);
  }

  Future<BudgetModel?> getMatchBudgetByTransaction(
      TransactionModel transaction, String username) async {
    final response = await ref
        .where('username', isEqualTo: username)
        .where('name', isEqualTo: transaction.name)
        .get();

    if (response.docs.isEmpty) return null;

    final doc = response.docs[0];
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final budget = BudgetModel.fromMap(data, doc.id);

    if (budget.beginDate.compareTo(transaction.date) <= 0 &&
        budget.endDate.compareTo(transaction.date) >= 0) {
      return budget;
    }
    return null;
  }
}
