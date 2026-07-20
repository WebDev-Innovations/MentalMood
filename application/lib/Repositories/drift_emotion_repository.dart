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
  Future<bool> updateEmotion(EmotionCompanion emotion) {
    return _db.updateEmotion(emotion);
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

  @override
  Future<void> deleteEmotion(int id) {
    return _db.deleteEmotion(id);
  }

  @override
  Future<int> addTag(MoodTagCompanion tag) {
    return _db.addTag(tag);
  }

  @override
  Future<List<MoodTagData>> getTagsForUser(int userId) {
    return _db.getTagsForUser(userId);
  }

  @override
  Future<int> deleteTag(int id) {
    return _db.deleteTag(id);
  }
}
