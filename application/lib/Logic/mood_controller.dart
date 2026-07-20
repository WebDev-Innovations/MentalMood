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

  List<MoodTagData> _availableTags = [];
  List<MoodTagData> get availableTags => _availableTags;

  List<BadgeData> _unlockedBadges = [];
  List<BadgeData> get unlockedBadges => _unlockedBadges;

  MoodRange _selectedRange = MoodRange.last7d;
  MoodRange get selectedRange => _selectedRange;

  void setSelectedRange(MoodRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  /// Saves a new emotion entry for the user and refreshes history
  Future<bool> saveMood({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await emotionRepository.addEmotion(EmotionCompanion.insert(
        value: value,
        userId: userId,
        createdAt: Value(DateTime.now()),
        note: Value(note),
        tags: Value(tags?.join(',')),
      ));
      
      await fetchMoodHistory(userId);
      await _checkAndUnlockBadges(userId);
      
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
      await fetchAvailableTags(userId);
      await fetchUnlockedBadges(userId);
      // Run a retroactive check for badges
      await _checkAndUnlockBadges(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Could not load history.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnlockedBadges(int userId) async {
    try {
      _unlockedBadges = await emotionRepository.getBadgesForUser(userId);
    } catch (e) {
      debugPrint("Error fetching badges: $e");
    }
  }

  Future<void> _checkAndUnlockBadges(int userId) async {
    if (_moodHistory.isEmpty) return;

    final streak = getStreak();
    final totalEntries = _moodHistory.length;
    final totalDays = _moodHistory.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet().length;

    bool badgeAdded = false;

    // Helper to unlock
    Future<void> unlock(String code, String title, String desc, String icon) async {
      if (!_unlockedBadges.any((b) => b.code == code)) {
        await emotionRepository.unlockBadge(BadgeCompanion.insert(
          code: code,
          title: title,
          description: desc,
          icon: icon,
          userId: userId,
          unlockedAt: Value(DateTime.now()),
        ));
        badgeAdded = true;
      }
    }

    // Streak Badges
    if (streak >= 3) await unlock('streak_3', 'On a Roll', '3 day mood streak!', '🔥');
    if (streak >= 7) await unlock('streak_7', 'Week Warrior', '7 day mood streak!', '⚡');
    if (streak >= 30) await unlock('streak_30', 'Dedicated', '30 day mood streak!', '💎');

    // Total Entry Badges
    if (totalEntries >= 10) await unlock('total_10', 'Getting Started', 'Logged 10 moods!', '🌱');
    if (totalEntries >= 50) await unlock('total_50', 'Mood Master', 'Logged 50 moods!', '🎓');
    if (totalEntries >= 100) await unlock('total_100', 'Centurion', 'Logged 100 moods!', '🏆');

    // Variety Badges
    final noteCount = _moodHistory.where((e) => e.note != null && e.note!.isNotEmpty).length;
    if (noteCount >= 5) await unlock('notes_5', 'Journalist', 'Added notes to 5 entries', '✍️');

    // --- SPECIAL/UNIQUE BADGES ---
    
    // 1. Early Bird (Logs between 5 AM and 8 AM)
    final hasEarlyBird = _moodHistory.any((e) => e.createdAt.hour >= 5 && e.createdAt.hour <= 8);
    if (hasEarlyBird) await unlock('special_early', 'Early Bird', 'Logged mood early morning', '🌅');

    // 2. Night Owl (Logs between 00 AM and 4 AM)
    final hasNightOwl = _moodHistory.any((e) => e.createdAt.hour >= 0 && e.createdAt.hour <= 4);
    if (hasNightOwl) await unlock('special_night', 'Night Owl', 'Logged mood late at night', '🦉');

    // 3. Zen Master (Search for ANY 3 consecutive entries with same value)
    if (_moodHistory.length >= 3) {
      bool foundZen = false;
      // Note: history is sorted newest to oldest
      for (int i = 0; i < _moodHistory.length - 2; i++) {
        if (_moodHistory[i].value == _moodHistory[i+1].value && 
            _moodHistory[i].value == _moodHistory[i+2].value) {
          foundZen = true;
          break;
        }
      }
      if (foundZen) await unlock('special_zen', 'Zen Master', 'Extreme stability (3x same)', '🧘');
    }

    // 4. Rollercoaster (Low and High mood in the same day)
    final Map<String, List<int>> dayValues = {};
    for (var e in _moodHistory) {
      final day = DateFormat('yyyy-MM-dd').format(e.createdAt);
      dayValues.putIfAbsent(day, () => []).add(e.value);
    }
    bool hasRollercoaster = false;
    dayValues.forEach((day, values) {
      if (values.any((v) => v <= 3) && values.any((v) => v >= 8)) hasRollercoaster = true;
    });
    if (hasRollercoaster) await unlock('special_roller', 'Rollercoaster', 'Highs and lows in one day', '🎢');

    // 5. Social Butterfly (Uses Family or Friends tags 5 times)
    final socialCount = _moodHistory.where((e) {
      if (e.tags == null) return false;
      return e.tags!.contains('Family') || e.tags!.contains('Friends');
    }).length;
    if (socialCount >= 5) await unlock('special_social', 'Butterfly', 'Connected with others 5 times', '🦋');

    if (badgeAdded) {
      await fetchUnlockedBadges(userId);
    }
  }

  Future<void> fetchAvailableTags(int userId) async {
    try {
      _availableTags = await emotionRepository.getTagsForUser(userId);
    } catch (e) {
      print("Error fetching tags: $e");
    }
  }

  Future<void> addCustomTag(String label, String emoji, int userId) async {
    try {
      await emotionRepository.addTag(MoodTagCompanion.insert(
        label: label,
        emoji: emoji,
        userId: Value(userId),
      ));
      await fetchAvailableTags(userId);
      notifyListeners();
    } catch (e) {
      print("Error adding tag: $e");
    }
  }

  Future<void> deleteTag(int tagId, int userId) async {
    try {
      await emotionRepository.deleteTag(tagId);
      await fetchAvailableTags(userId);
      notifyListeners();
    } catch (e) {
      print("Error deleting tag: $e");
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

  Future<void> deleteEmotion(int id, int userId) async {
    await emotionRepository.deleteEmotion(id);
    await fetchMoodHistory(userId);
  }

  Future<bool> updateEmotion({
    required int id,
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    required DateTime createdAt,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await emotionRepository.updateEmotion(EmotionCompanion(
        id: Value(id),
        userId: Value(userId),
        value: Value(value),
        note: Value(note),
        tags: Value(tags?.join(',')),
        createdAt: Value(createdAt),
      ));
      
      await fetchMoodHistory(userId);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = "Failed to update entry.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  int getStreak() {
    if (_moodHistory.isEmpty) return 0;

    final sortedEntries = List<EmotionData>.from(_moodHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Set<String> daysRecorded = sortedEntries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    if (!daysRecorded.contains(today) && !daysRecorded.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = daysRecorded.contains(today) ? now : now.subtract(const Duration(days: 1));

    while (daysRecorded.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int getLongestStreak() {
    if (_moodHistory.isEmpty) return 0;

    final sortedEntries = List<EmotionData>.from(_moodHistory)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final Set<String> daysRecorded = sortedEntries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();

    if (daysRecorded.isEmpty) return 0;

    List<String> sortedDays = daysRecorded.toList()..sort();
    
    int longest = 0;
    int current = 0;
    DateTime? lastDate;

    for (String dayStr in sortedDays) {
      DateTime date = DateTime.parse(dayStr);
      if (lastDate == null || date.difference(lastDate).inDays == 1) {
        current++;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
      lastDate = date;
    }

    return current > longest ? current : longest;
  }
}

class ChartMoodPoint {
  final DateTime date;
  final double value;
  ChartMoodPoint({required this.date, required this.value});
}
