import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/emotion_repository.dart';

class DriftEmotionRepository implements EmotionRepository {
  final AppDataBase _db;

  DriftEmotionRepository(this._db);

  @override
  Future<int> addEmotion(EmotionCompanion emotion) {
    return _db.addEmotion(emotion);
  }

  @override
  Future<List<EmotionData>> getEmotionsForUser(int userId) {
    return _db.getEmotionsForUser(userId);
  }

  @override
  Future<void> deleteAllEmotionsForUser(int userId) {
    return _db.deleteAllEmotionsForUser(userId);
  }

  @override
  Future<void> deleteEmotionsBefore(int userId, DateTime date) {
    return _db.deleteEmotionsBefore(userId, date);
  }
}
