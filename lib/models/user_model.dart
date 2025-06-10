class UserModel {
  String? id;
  String? username;
  int? income;
  String? email;

  UserModel({
    this.id,
    this.username,
    this.income,
    this.email,
  });

  /// Tạo một đối tượng từ Firestore document data
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] as String?,
      income: map['income'] is int
          ? map['income']
          : (map['income'] is double ? (map['income'] as double).toInt() : 0),
      email: map['email'] as String?,
    );
  }

  /// Chuyển dữ liệu thành Map để ghi vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'income': income ?? 0,
      'email': email,
    };
  }
}
