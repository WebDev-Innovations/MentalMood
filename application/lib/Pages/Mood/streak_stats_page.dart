import 'package:application/Logic/mood_controller.dart';
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
      appBar: AppBar(
        title: const Text("Streak Journey"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Streak Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 80, color: Colors.white),
                  Text(
                    "$streak",
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    "DAY STREAK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                _buildSimpleStat(context, "Best Record", "$longestStreak Days", Icons.emoji_events_rounded, Colors.amber),
                const SizedBox(width: 12),
                _buildSimpleStat(context, "Days Active", "$totalDays Days", Icons.calendar_today_rounded, Colors.blue),
                const SizedBox(width: 12),
                _buildSimpleStat(context, "Total Logs", "${history.length}", Icons.edit_note_rounded, AppTheme.primarySage),
              ],
            ),

            const SizedBox(height: 48),
            
            // Monthly Activity Heatmap
            Text("Activity Map", style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildMonthlyHeatmap(context, history),
            
            const SizedBox(height: 48),
            
            // Next Milestones
            Text("Next Milestones", style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildMilestones(streak),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeatmap(BuildContext context, List<dynamic> history) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startPadding = firstDayOfMonth.weekday - 1;

    final recordedDays = history
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
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
              color: isRecorded 
                  ? Colors.orange 
                  : (isToday ? Colors.orange.withOpacity(0.1) : theme.dividerColor.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(8),
              border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
            ),
            child: Center(
              child: Text(
                "$day",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isRecorded ? Colors.white : (isToday ? Colors.orange : Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestones(int currentStreak) {
    final milestones = [7, 14, 30, 50, 100, 365];
    return Column(
      children: milestones.map((m) {
        final isReached = currentStreak >= m;
        final progress = (currentStreak / m).clamp(0.0, 1.0);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Icon(
                isReached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isReached ? AppTheme.primarySage : Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$m Day Goal", style: TextStyle(
                          fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                          color: isReached ? null : Colors.grey,
                        )),
                        if (!isReached) Text("${m - currentStreak} to go", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        color: isReached ? AppTheme.primarySage : Colors.orange.withOpacity(0.5),
                        minHeight: 6,
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
