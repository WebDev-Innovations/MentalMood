import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:application/Utils/constants.dart';

part 'database.g.dart';

class User extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username=> text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get password => text()();
  DateTimeColumn get birthDate => dateTime()();
}

@DriftDatabase(tables: [User])
class AppDataBase extends _$AppDataBase {
  AppDataBase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Add these methods to handle user operations
  Future<int> createUser(UserCompanion entity) => into(user).insert(entity);
  Future<UserData?> getUser(String username) => 
      (select(user)..where((u) => u.username.equals(username))).getSingleOrNull();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Handle migrations here
      },
      beforeOpen: (details) async {
        // Seed the database with the default user if it's empty
        final users = await select(user).get();
        if (users.isEmpty) {
          await into(user).insert(UserCompanion.insert(
            username: AppConstants.adminUsername,
            name: 'Default',
            surname: 'User',
            password: AppConstants.hashedAdminPassword,
            birthDate: DateTime.now(),
          ));
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
