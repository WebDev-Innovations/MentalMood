import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:application/Utils/constants.dart';

part 'database.g.dart';

class User extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get password => text()();
  DateTimeColumn get birthDate => dateTime()();
}

class Emotion extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get value => integer().check(value.isBetweenValues(1, 10))();
  IntColumn get userId => integer().references(User, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [User, Emotion])
class AppDataBase extends _$AppDataBase {
  AppDataBase() : super(_openConnection());
  AppDataBase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2; // Increment schema version as we added a new table

  // User operations
  Future<int> createUser(UserCompanion entity) => into(user).insert(entity);
  Future<UserData?> getUser(String username) =>
      (select(user)..where((u) => u.username.equals(username))).getSingleOrNull();

  // Emotion operations
  Future<int> addEmotion(EmotionCompanion entity) => into(emotion).insert(entity);
  
  Future<List<EmotionData>> getEmotionsForUser(int userId) =>
      (select(emotion)..where((e) => e.userId.equals(userId))..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).get();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add the Emotion table when upgrading from version 1
          await m.createTable(emotion);
        }
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
