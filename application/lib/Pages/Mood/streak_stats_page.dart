import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StreakStatsPage extends StatelessWidget {
  const StreakStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final streak = moodController.getStreak();
    final longestStreak = moodController.getLongestStreak();
    final theme = Theme.of(context);
    final history = moodController.moodHistory;
    final totalDays = history.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet().length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Consistency"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Epic Streak Hero
            FadeInSlide(
              duration: 800,
              direction: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.amberWarm, Color(0xFFFF8A65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8A65).withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.4), 
                      blurRadius: 40, 
                      offset: const Offset(0, 15)
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 100, color: Colors.white),
                    TweenAnimationBuilder<int>(
                      duration: const Duration(milliseconds: 1500),
                      tween: IntTween(begin: 0, end: streak),
                      builder: (context, value, child) => Text(
                        "$value",
                        style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                      ),
                    ),
                    const Text(
                      "DAY STREAK",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 4, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Stats Grid
            FadeInSlide(
              duration: 1000,
              child: Row(
                children: [
                  _buildMetric(context, "Best", "$longestStreak", Icons.emoji_events_rounded, Colors.amber),
                  const SizedBox(width: 16),
                  _buildMetric(context, "Active", "$totalDays", Icons.calendar_today_rounded, Colors.blueAccent),
                  const SizedBox(width: 16),
                  _buildMetric(context, "Logs", "${history.length}", Icons.edit_note_rounded, theme.colorScheme.primary),
                ],
              ),
            ),
            
            const SizedBox(height: 56),
            
            _buildSectionLabel(context, "Activity: ${DateFormat('MMMM yyyy').format(DateTime.now())}"),
            const SizedBox(height: 16),
            _buildMonthlyHeatmap(context, history),
            
            const SizedBox(height: 48),
            
            _buildSectionLabel(context, "Upcoming Goals"),
            const SizedBox(height: 16),
            _buildMilestones(context, streak),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w800, 
          letterSpacing: 2, 
          fontSize: 11, 
          color: theme.colorScheme.onSurface.withOpacity(0.3)
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.02),
              blurRadius: 20, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(
              label.toUpperCase(), 
              style: TextStyle(
                fontSize: 9, 
                fontWeight: FontWeight.w800, 
                color: theme.colorScheme.onSurface.withOpacity(0.3)
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeatmap(BuildContext context, List<dynamic> history) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startPadding = DateTime(now.year, now.month, 1).weekday - 1;
    final recordedDays = history.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(40)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10,
        ),
        itemCount: daysInMonth + startPadding,
        itemBuilder: (context, index) {
          if (index < startPadding) return const SizedBox.shrink();
          final day = index - startPadding + 1;
          final dateStr = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day));
          final isRecorded = recordedDays.contains(dateStr);
          final isToday = day == now.day;

          return Container(
            decoration: BoxDecoration(
              color: isRecorded ? AppTheme.amberWarm : (isToday ? AppTheme.amberWarm.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: AppTheme.amberWarm, width: 2) : null,
            ),
            child: Center(
              child: Text("$day", style: TextStyle(
                fontSize: 13, fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isRecorded ? Colors.white : (isToday ? AppTheme.amberWarm : theme.colorScheme.onSurface.withOpacity(0.2)),
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestones(BuildContext context, int streak) {
    final theme = Theme.of(context);
    final milestones = [7, 14, 30, 50, 100];
    return Column(
      children: milestones.map((m) {
        final progress = (streak / m).clamp(0.0, 1.0);
        final isReached = streak >= m;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Icon(
                isReached ? Icons.stars_rounded : Icons.lock_outline_rounded, 
                color: isReached ? AppTheme.amberWarm : theme.colorScheme.onSurface.withOpacity(0.1), 
                size: 40
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$m Day Goal", 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 16, 
                        color: isReached ? null : theme.colorScheme.onSurface.withOpacity(0.3)
                      )
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.03),
                        color: isReached ? theme.colorScheme.primary : AppTheme.amberWarm.withOpacity(0.4),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
