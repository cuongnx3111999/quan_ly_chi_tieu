import 'package:money_grower/models/user_model.dart';
import 'package:money_grower/resources/repository.dart';

class UserBloc {
  final repository = Repository();
  Future getUserByUsername(String username) => repository.getUserByUsername(username);
  Future insertUser(UserModel data) => repository.insertUser(data);
  Future updateUser(UserModel data, String id) => repository.updateUser(data);
}