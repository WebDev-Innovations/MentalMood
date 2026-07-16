import 'dart:math';
import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MoodRange { last24h, last7d, last30d, lastYear }

class MoodController extends ChangeNotifier {
  final EmotionRepository emotionRepository;

  MoodController({required this.emotionRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<EmotionData> _moodHistory = [];
  List<EmotionData> get moodHistory => _moodHistory;

  MoodRange _selectedRange = MoodRange.last7d;
  MoodRange get selectedRange => _selectedRange;

  void setSelectedRange(MoodRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  /// Saves a new emotion entry for the user and refreshes history
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
      
      await fetchMoodHistory(userId);
      
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

  /// Fetches the mood history for a specific user
  Future<void> fetchMoodHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodHistory = await emotionRepository.getEmotionsForUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Could not load history.";
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seeds the database with random mood data for the last 60 days
  Future<void> seedMockData(int userId) async {
    final Random random = Random();
    final now = DateTime.now();
    
    // Generate data for the last 60 days
    for (int i = 60; i >= 0; i--) {
      // 1 to 3 entries per day to simulate real usage
      final entriesPerDay = random.nextInt(3) + 1;
      
      for (int j = 0; j < entriesPerDay; j++) {
        final date = now.subtract(Duration(days: i, hours: random.nextInt(24), minutes: random.nextInt(60)));
        final value = random.nextInt(10) + 1; // 1 to 10
        
        await emotionRepository.addEmotion(EmotionCompanion.insert(
          value: value,
          userId: userId,
          createdAt: Value(date),
        ));
      }
    }
    await fetchMoodHistory(userId);
  }

  /// Deletes all history for the user
  Future<void> clearHistory(int userId) async {
    await emotionRepository.deleteAllEmotionsForUser(userId);
    _moodHistory = [];
    notifyListeners();
  }

  /// Deletes history before a specific date
  Future<void> clearHistoryBefore(int userId, DateTime date) async {
    await emotionRepository.deleteEmotionsBefore(userId, date);
    await fetchMoodHistory(userId);
  }

  /// Returns processed data for the chart based on the selected range
  List<ChartMoodPoint> getChartData() {
    if (_moodHistory.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;
    bool groupByDay = false;
    bool groupByMonth = false;

    switch (_selectedRange) {
      case MoodRange.last24h:
        cutoff = now.subtract(const Duration(hours: 24));
        groupByDay = false;
        break;
      case MoodRange.last7d:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        groupByDay = true;
        break;
      case MoodRange.last30d:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        groupByDay = true;
        break;
      case MoodRange.lastYear:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
        groupByMonth = true;
        break;
    }

    final filtered = _moodHistory.where((e) => e.createdAt.isAfter(cutoff)).toList();
    // Sort oldest to newest for the chart
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (_selectedRange == MoodRange.last24h) {
      return filtered.map((e) => ChartMoodPoint(date: e.createdAt, value: e.value.toDouble())).toList();
    }

    if (groupByMonth) {
      // Group by month and average
      final Map<String, List<double>> groups = {};
      for (var e in filtered) {
        final monthKey = DateFormat('yyyy-MM').format(e.createdAt);
        groups.putIfAbsent(monthKey, () => []).add(e.value.toDouble());
      }

      final List<ChartMoodPoint> result = [];
      groups.forEach((month, values) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        result.add(ChartMoodPoint(date: DateTime.parse("$month-01"), value: avg));
      });
      return result;
    }

    if (groupByDay) {
      // Group by day and average
      final Map<String, List<double>> groups = {};
      for (var e in filtered) {
        final dayKey = DateFormat('yyyy-MM-dd').format(e.createdAt);
        groups.putIfAbsent(dayKey, () => []).add(e.value.toDouble());
      }

      final List<ChartMoodPoint> result = [];
      groups.forEach((day, values) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        result.add(ChartMoodPoint(date: DateTime.parse(day), value: avg));
      });

      return result;
    }

    return [];
  }

  String getMoodSummary() {
    if (_moodHistory.isEmpty) return "No data yet. Start tracking!";
    
    final latestMood = _moodHistory.first.value;
    if (latestMood <= 3) return "You've been feeling down lately. Take some time for yourself.";
    if (latestMood <= 6) return "You're doing okay. Keep finding moments of peace.";
    if (latestMood <= 8) return "You're feeling good! Keep up the positive energy.";
    return "You're feeling amazing! Enjoy this beautiful moment.";
  }

  double? getTodayAverage() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEntries = _moodHistory.where((e) => e.createdAt.isAfter(todayStart)).toList();
    
    if (todayEntries.isEmpty) return null;
    
    final sum = todayEntries.map((e) => e.value).reduce((a, b) => a + b);
    return sum / todayEntries.length;
  }

  Map<String, dynamic> getTodayStatus() {
    final avg = getTodayAverage();
    if (avg == null) return {"label": "No entries yet", "emoji": "🌱", "color": Colors.grey};
    
    if (avg <= 2.5) return {"label": "Tough Day", "emoji": "😫", "color": Colors.redAccent};
    if (avg <= 4.5) return {"label": "Bit Rough", "emoji": "🙁", "color": Colors.orangeAccent};
    if (avg <= 6.5) return {"label": "Steady", "emoji": "😐", "color": Colors.blueAccent};
    if (avg <= 8.5) return {"label": "Good Day", "emoji": "🙂", "color": const Color(0xFF6DA48D)};
    return {"label": "Fantastic!", "emoji": "🤩", "color": Colors.orange};
  }
}

class ChartMoodPoint {
  final DateTime date;
  final double value;
  ChartMoodPoint({required this.date, required this.value});
}
