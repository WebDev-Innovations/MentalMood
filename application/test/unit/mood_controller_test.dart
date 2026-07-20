import 'package:application/DataBase/database.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmotionRepository extends Mock implements EmotionRepository {}

void main() {
  late MoodController moodController;
  late MockEmotionRepository mockEmotionRepository;

  setUpAll(() {
    registerFallbackValue(const EmotionCompanion());
    registerFallbackValue(const MoodTagCompanion());
    registerFallbackValue(const BadgeCompanion());
  });

  setUp(() {
    mockEmotionRepository = MockEmotionRepository();
    moodController = MoodController(emotionRepository: mockEmotionRepository);
    
    // Default mock behavior
    when(() => mockEmotionRepository.getEmotionsForUser(any()))
        .thenAnswer((_) async => []);
    when(() => mockEmotionRepository.getTagsForUser(any()))
        .thenAnswer((_) async => []);
    when(() => mockEmotionRepository.getBadgesForUser(any()))
        .thenAnswer((_) async => []);
  });

  group('MoodController Streak Tests', () {
    test('Streak is 0 when history is empty', () {
      expect(moodController.getStreak(), 0);
    });

    test('Streak is 1 when only today is recorded', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);
          
      await moodController.fetchMoodHistory(1);
      expect(moodController.getStreak(), 1);
    });

    test('Streak is 2 when today and yesterday are recorded', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now),
        EmotionData(id: 2, value: 6, userId: 1, createdAt: now.subtract(const Duration(days: 1))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);
          
      await moodController.fetchMoodHistory(1);
      expect(moodController.getStreak(), 2);
    });

    test('Streak is 0 if no records today or yesterday', () async {
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);
          
      await moodController.fetchMoodHistory(1);
      expect(moodController.getStreak(), 0);
    });
  });

  group('MoodController Badge Tests', () {
    test('saveMood checks for badges', () async {
      when(() => mockEmotionRepository.addEmotion(any()))
          .thenAnswer((_) async => 1);
      when(() => mockEmotionRepository.unlockBadge(any()))
          .thenAnswer((_) async => 1);
      
      // Mock history with 2 previous days + today being saved
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now),
        EmotionData(id: 2, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 1))),
        EmotionData(id: 3, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 2))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);

      await moodController.saveMood(userId: 1, value: 8);
      
      // Should check if streak_3 is unlocked
      verify(() => mockEmotionRepository.unlockBadge(any())).called(greaterThan(0));
    });
  });
}
