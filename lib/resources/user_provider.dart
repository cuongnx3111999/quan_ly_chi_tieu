import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider {
  final CollectionReference doc = FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUserByUsername(String username) async {
    final querySnapshot = await doc.where('username', isEqualTo: username).limit(1).get();
    if (querySnapshot.docs.isEmpty) return null;
    final docSnapshot = querySnapshot.docs.first;
    return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
  }

  Future<void> updateUser(UserModel data) async {
    await doc.doc(data.id).update(data.toJson());
  }

  Future<void> insertUser(UserModel data) async {
    await doc.add(data.toJson());
  }
}
