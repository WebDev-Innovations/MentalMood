import 'package:application/DataBase/database.dart';

abstract class EmotionRepository {
  Future<int> addEmotion(EmotionCompanion emotion);
  Future<bool> updateEmotion(EmotionCompanion emotion);
  Future<List<EmotionData>> getEmotionsForUser(int userId);
  Future<void> deleteAllEmotionsForUser(int userId);
  Future<void> deleteEmotionsBefore(int userId, DateTime date);
  Future<void> deleteEmotion(int id);

  // Tag operations
  Future<int> addTag(MoodTagCompanion tag);
  Future<List<MoodTagData>> getTagsForUser(int userId);
  Future<int> deleteTag(int id);
}
