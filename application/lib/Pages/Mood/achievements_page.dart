import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final unlockedBadges = moodController.unlockedBadges;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadgeCategory(context, "Milestones", [
              {'code': 'streak_7', 'title': 'Week Warrior', 'icon': '⚡', 'desc': '7 day streak'},
              {'code': 'streak_30', 'title': 'Dedicated', 'icon': '💎', 'desc': '30 day streak'},
              {'code': 'total_50', 'title': 'Mood Master', 'icon': '🎓', 'desc': '50 logs total'},
            ], unlockedBadges),

            const SizedBox(height: 32),

            _buildBadgeCategory(context, "Special Achievements", [
              {'code': 'special_early', 'title': 'Early Bird', 'icon': '🌅', 'desc': 'Logged at dawn'},
              {'code': 'special_night', 'title': 'Night Owl', 'icon': '🦉', 'desc': 'Logged late night'},
              {'code': 'special_zen', 'title': 'Zen Master', 'icon': '🧘', 'desc': '3x same mood'},
              {'code': 'special_roller', 'title': 'Rollercoaster', 'icon': '🎢', 'desc': 'Highs & Lows'},
              {'code': 'special_social', 'title': 'Butterfly', 'icon': '🦋', 'desc': '5x Social tags'},
              {'code': 'notes_5', 'title': 'Journalist', 'icon': '✍️', 'desc': '5 detailed notes'},
            ], unlockedBadges),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Keep tracking to unlock more!",
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCategory(BuildContext context, String category, List<Map<String, String>> badges, List<dynamic> unlocked) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final isUnlocked = unlocked.any((b) => b.code == badge['code']);
            
            return Container(
              decoration: BoxDecoration(
                color: isUnlocked ? AppTheme.primarySage.withOpacity(0.08) : theme.dividerColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: isUnlocked 
                  ? Border.all(color: AppTheme.primarySage.withOpacity(0.3), width: 1.5)
                  : Border.all(color: theme.dividerColor.withOpacity(0.05), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: isUnlocked ? 1.0 : 0.2,
                    child: Text(badge['icon']!, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? theme.colorScheme.onSurface : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge['desc']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
