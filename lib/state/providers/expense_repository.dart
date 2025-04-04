import 'dart:async';
import 'dart:io';
import '../../models/expense.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class ExpenseRepository {
  final DatabaseService _databaseService;
  final StorageService _storageService;

  ExpenseRepository({required String userId})
      : _databaseService = DatabaseService(userId: userId),
        _storageService = StorageService(userId: userId);

  // Lấy danh sách chi tiêu
  Stream<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) {
    return _databaseService.getExpenses(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
    );
  }

  // Thêm chi tiêu mới với hình ảnh (nếu có)
  Future<String> addExpense(Expense expense, [File? image]) async {
    String? imageUrl;

    // Tải lên hình ảnh nếu có
    if (image != null) {
      imageUrl = await _storageService.uploadExpenseImage(image);
    }

    // Tạo expense với imageUrl
    final finalExpense = imageUrl != null
        ? expense.copyWith(imageUrl: imageUrl)
        : expense;

    // Thêm vào Firestore
    return await _databaseService.addExpense(finalExpense);
  }

  // Cập nhật chi tiêu
  Future<void> updateExpense(Expense expense, [File? newImage]) async {
    Expense updatedExpense = expense;

    // Xử lý hình ảnh mới nếu có
    if (newImage != null) {
      // Xóa hình ảnh cũ nếu có
      if (expense.imageUrl != null) {
        await _storageService.deleteExpenseImage(expense.imageUrl!);
      }

      // Tải lên hình ảnh mới
      final newImageUrl = await _storageService.uploadExpenseImage(newImage);
      updatedExpense = expense.copyWith(imageUrl: newImageUrl);
    }

    // Cập nhật trong Firestore
    await _databaseService.updateExpense(updatedExpense);
  }

  // Xóa chi tiêu
  Future<void> deleteExpense(String expenseId, [String? imageUrl]) async {
    // Xóa hình ảnh nếu có
    if (imageUrl != null) {
      await _storageService.deleteExpenseImage(imageUrl);
    }

    // Xóa chi tiêu
    await _databaseService.deleteExpense(expenseId);
  }

  // Lấy thống kê chi tiêu theo danh mục
  Future<Map<String, double>> getExpensesByCategory(
      DateTime startDate, DateTime endDate) {
    return _databaseService.getExpensesByCategory(startDate, endDate);
  }

  // Lấy thống kê chi tiêu theo tháng
  Future<Map<String, double>> getMonthlyExpenses(
      DateTime startDate, DateTime endDate) {
    return _databaseService.getMonthlyExpenses(startDate, endDate);
  }
}