import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String? currency; // Đơn vị tiền tệ mặc định
  final Map<String, dynamic>? settings; // Lưu các thiết lập của người dùng

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.currency = 'VND',
    this.settings,
  });

  // Tạo UserModel từ document Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      currency: data['currency'] ?? 'VND',
      settings: data['settings'],
    );
  }

  // Chuyển đổi UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'currency': currency,
      'settings': settings ?? {},
    };
  }

  // Tạo bản sao của UserModel với một số thuộc tính được cập nhật
  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? currency,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: this.createdAt,
      currency: currency ?? this.currency,
      settings: settings ?? this.settings,
    );
  }
}