import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/expense.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final StorageService _storageService;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedStartDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();
  String? _selectedCategoryId;

  ExpenseProvider({
    required String userId,
  }) : _databaseService = DatabaseService(userId: userId),
        _storageService = StorageService(userId: userId) {
    _loadExpenses();
  }

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedStartDate => _selectedStartDate;
  DateTime get selectedEndDate => _selectedEndDate;
  String? get selectedCategoryId => _selectedCategoryId;

  // Lấy chi tiêu
  void _loadExpenses() {
    _isLoading = true;
    notifyListeners();

    _databaseService
        .getExpenses(
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      categoryId: _selectedCategoryId,
    )
        .listen(
          (expensesList) {
        _expenses = expensesList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Lỗi khi lấy dữ liệu chi tiêu: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Thay đổi bộ lọc
  void setFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) {
    bool shouldReload = false;

    if (startDate != null && startDate != _selectedStartDate) {
      _selectedStartDate = startDate;
      shouldReload = true;
    }

    if (endDate != null && endDate != _selectedEndDate) {
      _selectedEndDate = endDate;
      shouldReload = true;
    }

    if (categoryId != _selectedCategoryId) {
      _selectedCategoryId = categoryId;
      shouldReload = true;
    }

    if (shouldReload) {
      _loadExpenses();
    }
  }

  // Thêm chi tiêu
  Future<bool> addExpense(Expense expense, [File? image]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl;

      // Nếu có hình ảnh, tải lên Firebase Storage
      if (image != null) {
        imageUrl = await _storageService.uploadExpenseImage(image);
      }

      // Tạo expense với imageUrl nếu có
      final finalExpense = image != null
          ? expense.copyWith(imageUrl: imageUrl)
          : expense;

      // Thêm vào Firestore
      await _databaseService.addExpense(finalExpense);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Lỗi khi thêm chi tiêu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cập nhật chi tiêu
  Future<bool> updateExpense(Expense expense, [File? newImage]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Expense updatedExpense = expense;

      // Nếu có hình ảnh mới
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Lỗi khi cập nhật chi tiêu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa chi tiêu
  Future<bool> deleteExpense(String expenseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Tìm khoản chi tiêu trong danh sách
      final expense = _expenses.firstWhere((e) => e.id == expenseId);

      // Xóa hình ảnh nếu có
      if (expense.imageUrl != null) {
        await _storageService.deleteExpenseImage(expense.imageUrl!);
      }

      // Xóa chi tiêu từ Firestore
      await _databaseService.deleteExpense(expenseId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Lỗi khi xóa chi tiêu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Lấy tổng chi tiêu trong khoảng thời gian hiện tại
  double get totalExpense {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Lấy chi tiêu theo ngày
  Map<DateTime, List<Expense>> get expensesByDay {
    Map<DateTime, List<Expense>> result = {};

    for (var expense in _expenses) {
      // Chuẩn hóa DateTime chỉ giữ ngày (không giờ, phút, giây)
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      if (!result.containsKey(date)) {
        result[date] = [];
      }

      result[date]!.add(expense);
    }

    return result;
  }
}