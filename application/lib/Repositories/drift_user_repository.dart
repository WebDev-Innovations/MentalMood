import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/user_repository.dart';

class DriftUserRepository implements UserRepository {
  final AppDataBase _db;

  DriftUserRepository(this._db);

  @override
  Future<UserData?> getUserByUsername(String username) {
    return _db.getUser(username);
  }

  @override
  Future<int> createUser(UserCompanion user) {
    return _db.createUser(user);
  }
}
