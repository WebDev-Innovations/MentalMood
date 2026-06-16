import 'package:application/DataBase/database.dart';

abstract class EmotionRepository {
  Future<int> addEmotion(EmotionCompanion emotion);
  Future<List<EmotionData>> getEmotionsForUser(int userId);
  Future<void> deleteAllEmotionsForUser(int userId);
}
