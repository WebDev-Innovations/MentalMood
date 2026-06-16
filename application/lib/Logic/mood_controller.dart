import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class MoodController extends ChangeNotifier {
  final EmotionRepository emotionRepository;

  MoodController({required this.emotionRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Saves a new emotion entry for the user
  Future<bool> saveMood({required int userId, required int value}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await emotionRepository.addEmotion(EmotionCompanion.insert(
        value: value,
        userId: userId,
        createdAt: Value(DateTime.now()),
      ));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to save your mood. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
