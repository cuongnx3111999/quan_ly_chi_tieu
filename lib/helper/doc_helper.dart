import 'package:cloud_firestore/cloud_firestore.dart';

class DocHelper {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference ref;

  DocHelper(String path) : ref = FirebaseFirestore.instance.collection(path);
  // DocHelper(String path) {
  //   ref = db.collection(path);
  // }
}
