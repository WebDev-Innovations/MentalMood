import 'package:application/DataBase/database.dart';

abstract class UserRepository {
  Future<UserData?> getUserByUsername(String username);
  Future<int> createUser(UserCompanion user);
}
