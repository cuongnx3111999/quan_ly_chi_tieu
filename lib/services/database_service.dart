import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  DatabaseService({required this.userId});

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get expensesCollection =>
      _firestore.collection('expenses');
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');
  CollectionReference get budgetsCollection => _firestore.collection('budgets');

  // User methods
  Future<UserModel?> getUserData() async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      return doc.exists ? UserModel.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Expense methods
  Future<String> addExpense(Expense expense) async {
    try {
      DocumentReference docRef = await expensesCollection.add(expense.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        throw Exception('Cannot update expense without ID');
      }
      await expensesCollection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await expensesCollection.doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  Stream<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) {
    Query query = expensesCollection.where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  // Category methods
  Future<void> initDefaultCategories() async {
    try {
      // Kiểm tra xem đã có danh mục nào chưa
      final snapshot =
          await categoriesCollection
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        // Nếu chưa có, thêm các danh mục mặc định
        final batch = _firestore.batch();

        for (var category in Category.defaultCategories(userId)) {
          final docRef = categoriesCollection.doc();
          batch.set(docRef, category.toMap());
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  Future<String> addCategory(Category category) async {
    try {
      DocumentReference docRef = await categoriesCollection.add(
        category.toMap(),
      );
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        throw Exception('Cannot update category without ID');
      }
      await categoriesCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      // Kiểm tra xem danh mục đã được sử dụng trong khoản chi tiêu nào chưa
      final expenseSnapshot =
          await expensesCollection
              .where('categoryId', isEqualTo: categoryId)
              .limit(1)
              .get();

      if (expenseSnapshot.docs.isNotEmpty) {
        throw Exception(
          'Cannot delete category that is being used by expenses',
        );
      }

      await categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  Stream<List<Category>> getCategories({bool? isExpense}) {
    Query query = categoriesCollection.where('userId', isEqualTo: userId);

    if (isExpense != null) {
      query = query.where('isExpense', isEqualTo: isExpense);
    }

    return query
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
        );
  }

  // Budget methods
  Future<String> addBudget(Budget budget) async {
    try {
      DocumentReference docRef = await budgetsCollection.add(budget.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding budget: $e');
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      if (budget.id == null) {
        throw Exception('Cannot update budget without ID');
      }
      await budgetsCollection.doc(budget.id).update(budget.toMap());
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await budgetsCollection.doc(budgetId).delete();
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }

  Stream<List<Budget>> getBudgets({DateTime? activeDate, String? categoryId}) {
    Query query = budgetsCollection.where('userId', isEqualTo: userId);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      final budgets =
          snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();

      // Lọc theo ngày hoạt động nếu cần
      if (activeDate != null) {
        return budgets
            .where(
              (budget) =>
                  budget.startDate.isBefore(activeDate) &&
                  budget.endDate.isAfter(activeDate),
            )
            .toList();
      }

      return budgets;
    });
  }

  // Thống kê chi tiêu theo danh mục trong khoảng thời gian
  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot =
          await expensesCollection
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      Map<String, double> result = {};

      for (var doc in snapshot.docs) {
        final expense = Expense.fromFirestore(doc);
        result[expense.categoryId] =
            (result[expense.categoryId] ?? 0) + expense.amount;
      }

      return result;
    } catch (e) {
      print('Error getting expenses by category: $e');
      return {};
    }
  }

  // Tổng chi tiêu theo tháng trong khoảng thời gian
  Future<Map<String, double>> getMonthlyExpenses(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot =
          await expensesCollection
              .where('userId', isEqualTo: userId)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .get();

      Map<String, double> monthlyTotals = {};

      for (var doc in snapshot.docs) {
        final expense = Expense.fromFirestore(doc);
        final monthKey =
            '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';

        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }

      return monthlyTotals;
    } catch (e) {
      print('Error getting monthly expenses: $e');
      return {};
    }
  }
}
