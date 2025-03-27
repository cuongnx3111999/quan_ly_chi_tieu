import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userId;

  StorageService({required this.userId});

  // Tải lên hình ảnh và trả về URL
  Future<String> uploadExpenseImage(File imageFile) async {
    try {
      // Tạo tên file duy nhất
      String fileName = '${Uuid().v4()}${path.extension(imageFile.path)}';

      // Tham chiếu đến vị trí lưu trữ
      final Reference reference = _storage
          .ref()
          .child('expense_images')
          .child(userId)
          .child(fileName);

      // Tải lên file
      final UploadTask uploadTask = reference.putFile(imageFile);

      // Đợi tải lên hoàn tất
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL tải xuống
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Xóa hình ảnh từ URL
  Future<void> deleteExpenseImage(String imageUrl) async {
    try {
      // Lấy tham chiếu từ URL
      final Reference reference = _storage.refFromURL(imageUrl);

      // Xóa file
      await reference.delete();
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
}
