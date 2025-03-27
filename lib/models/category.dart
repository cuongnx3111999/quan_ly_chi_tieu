import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String? id;
  final String name; // Tên danh mục
  final int iconData; // Mã của biểu tượng (IconData.codePoint)
  final int colorValue; // Giá trị màu sắc
  final String
  userId; // ID của người dùng tạo danh mục (null nếu là danh mục mặc định)
  final bool isDefault; // Danh mục mặc định hay tùy chỉnh
  final String? parentId; // Danh mục cha (nếu là danh mục con)
  final bool isExpense; // Loại danh mục (chi tiêu hoặc thu nhập)

  Category({
    this.id,
    required this.name,
    required this.iconData,
    required this.colorValue,
    required this.userId,
    this.isDefault = false,
    this.parentId,
    this.isExpense = true,
  });

  // Chuyển đổi codePoint thành IconData
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');

  // Chuyển đổi giá trị màu thành Color
  Color get color => Color(colorValue);

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      iconData: data['iconData'] ?? Icons.category.codePoint,
      colorValue: data['colorValue'] ?? Colors.blue.value,
      userId: data['userId'] ?? '',
      isDefault: data['isDefault'] ?? false,
      parentId: data['parentId'],
      isExpense: data['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconData': iconData,
      'colorValue': colorValue,
      'userId': userId,
      'isDefault': isDefault,
      'parentId': parentId,
      'isExpense': isExpense,
    };
  }

  Category copyWith({
    String? name,
    int? iconData,
    int? colorValue,
    bool? isDefault,
    String? parentId,
    bool? isExpense,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      colorValue: colorValue ?? this.colorValue,
      userId: userId,
      isDefault: isDefault ?? this.isDefault,
      parentId: parentId ?? this.parentId,
      isExpense: isExpense ?? this.isExpense,
    );
  }

  // Danh sách các danh mục mặc định
  static List<Category> defaultCategories(String userId) {
    return [
      Category(
        name: 'Ăn uống',
        iconData: Icons.restaurant.codePoint,
        colorValue: Colors.orange.value,
        userId: userId,
        isDefault: true,
        isExpense: true,
      ),
      Category(
        name: 'Di chuyển',
        iconData: Icons.directions_car.codePoint,
        colorValue: Colors.blue.value,
        userId: userId,
        isDefault: true,
        isExpense: true,
      ),
      Category(
        name: 'Mua sắm',
        iconData: Icons.shopping_bag.codePoint,
        colorValue: Colors.purple.value,
        userId: userId,
        isDefault: true,
        isExpense: true,
      ),
      Category(
        name: 'Hóa đơn',
        iconData: Icons.receipt.codePoint,
        colorValue: Colors.red.value,
        userId: userId,
        isDefault: true,
        isExpense: true,
      ),
      Category(
        name: 'Lương',
        iconData: Icons.attach_money.codePoint,
        colorValue: Colors.green.value,
        userId: userId,
        isDefault: true,
        isExpense: false,
      ),
      // Thêm các danh mục mặc định khác ở đây
    ];
  }
}
