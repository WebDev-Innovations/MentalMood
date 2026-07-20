import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Trophy Room"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategory(context, "Journaling Milestones", [
              {'code': 'streak_7', 'title': 'Full Week', 'icon': '⚡', 'desc': '7 day streak'},
              {'code': 'streak_30', 'title': 'Commitment', 'icon': '💎', 'desc': '30 day streak'},
              {'code': 'total_50', 'title': 'Half Century', 'icon': '🎓', 'desc': '50 logs'},
            ], unlockedBadges),
            
            const SizedBox(height: 48),
            
            _buildCategory(context, "Special Moments", [
              {'code': 'special_early', 'title': 'Dawn Patrol', 'icon': '🌅', 'desc': 'Early morning log'},
              {'code': 'special_night', 'title': 'Night Watch', 'icon': '🦉', 'desc': 'Late night log'},
              {'code': 'special_zen', 'title': 'Equilibrium', 'icon': '🧘', 'desc': '3x same mood'},
              {'code': 'special_roller', 'title': 'Human', 'icon': '🎢', 'desc': 'Highs & Lows'},
              {'code': 'special_social', 'title': 'Connection', 'icon': '🦋', 'desc': 'Social butterfly'},
              {'code': 'notes_5', 'title': 'Journalist', 'icon': '✍️', 'desc': '5 detailed notes'},
            ], unlockedBadges),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<Map<String, String>> badges, List<dynamic> unlocked) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(), 
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            letterSpacing: 2, 
            fontSize: 11, 
            color: theme.colorScheme.onSurface.withOpacity(0.3)
          )
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.9,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final isUnlocked = unlocked.any((b) => b.code == badge['code']);
            return ScaleIn(
              delay: index * 100,
              child: HoverEffect(
                scale: 1.05,
                child: _AchievementCard(badge: badge, isUnlocked: isUnlocked),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Map<String, String> badge;
  final bool isUnlocked;
  const _AchievementCard({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnlocked ? theme.colorScheme.surface : theme.colorScheme.onSurface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(40),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.02), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ] : null,
        border: Border.all(
          color: isUnlocked ? AppTheme.sandAccent.withOpacity(0.5) : Colors.transparent, 
          width: 1.5
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.2,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUnlocked ? AppTheme.sandAccent.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(badge['icon']!, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            badge['title']!, 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 15, 
              color: isUnlocked ? null : theme.colorScheme.onSurface.withOpacity(0.4)
            )
          ),
          const SizedBox(height: 4),
          Text(
            badge['desc']!, 
            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.25)),
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }
}
