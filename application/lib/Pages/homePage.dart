import 'dart:math';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Pages/Mood/add_mood_page.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginController>().currentUser;
      if (user != null) {
        context.read<MoodController>().fetchMoodHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.watch<LoginController>().currentUser;
    final theme = Theme.of(context);
    final status = moodController.getTodayStatus();
    final chartData = moodController.getChartData();
    final streak = moodController.getStreak();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: theme.colorScheme.onSurface.withOpacity(0.3)
              ),
            ),
            Text(
              "Hello, ${user?.name ?? 'Friend'}",
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ],
        ),
        actions: [
          HoverEffect(
            scale: 1.05, // Safer scale for top pills
            child: _buildTopIconPill(context, Icons.emoji_events_rounded, "/achievements", AppTheme.sandAccent.withOpacity(0.4)),
          ),
          const SizedBox(width: 8),
          HoverEffect(
            scale: 1.02,
            child: _buildStreakPill(context, streak),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await moodController.fetchMoodHistory(user.id);
          }
        },
        color: AppTheme.sagePrimary,
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          clipBehavior: Clip.none, // Essential to see hover scale expansion on all sides
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInSlide(
                duration: 400,
                child: Text(
                  "How are you feeling today?", 
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)
                ),
              ),
              const SizedBox(height: 24),
              
              FadeInSlide(
                duration: 500,
                child: HoverEffect(
                  scale: 1.01, // Subtle scale for large cards to avoid edge overflow
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMoodPage())),
                    borderRadius: BorderRadius.circular(32),
                    child: _buildStatusCard(status),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              FadeInSlide(
                duration: 600,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Your Journey", style: theme.textTheme.titleLarge),
                    _RangeSelector(
                      selectedRange: moodController.selectedRange,
                      onChanged: (range) => moodController.setSelectedRange(range),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              FadeInSlide(
                duration: 700,
                child: _buildChartCard(chartData, moodController),
              ),
              
              const SizedBox(height: 32),
              
              FadeInSlide(
                duration: 800,
                child: HoverEffect(
                  scale: 1.01,
                  child: _buildInsightCard(moodController.getMoodSummary()),
                ),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FadeInSlide(
        duration: 900,
        direction: Offset.zero,
        child: _buildFAB(context),
      ),
    );
  }

  Widget _buildTopIconPill(BuildContext context, IconData icon, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 20, color: AppTheme.sagePrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakPill(BuildContext context, int streak) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/streak'),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text("$streak", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> status) {
    final color = status['color'] as Color;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(32)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Text(status['emoji'], style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TODAY IS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.grey)),
                Text(status['label'], style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<ChartMoodPoint> data, MoodController controller) {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 40)],
      ),
      child: data.isEmpty 
          ? const Center(child: Text("Start tracking to see data")) 
          : _LineChartWidget(data: data, range: controller.selectedRange),
    );
  }

  Widget _buildInsightCard(String summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 18),
              SizedBox(width: 8),
              Text("WEEKLY INSIGHT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("COMING SOON...", style: TextStyle(height: 1.5, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3436),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/zen'),
            icon: const Icon(Icons.emergency_rounded, color: AppTheme.accent),
          ),
          const VerticalDivider(color: Colors.white10, indent: 20, endIndent: 20),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AddMoodPage())),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("CHECK-IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<ChartMoodPoint> data;
  final MoodRange range;
  const _LineChartWidget({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final double minYData = data.isEmpty ? 0 : data.map((e) => e.value).reduce(min);
    final double maxYData = data.isEmpty ? 10 : data.map((e) => e.value).reduce(max);
    
    double lineStop = 0.5;
    if (maxYData != minYData) {
      lineStop = (5.0 - minYData) / (maxYData - minYData);
    } else {
      lineStop = maxYData >= 5.0 ? 0.0 : 1.0;
    }
    lineStop = lineStop.clamp(0.0, 1.0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        minX: 0,
        maxX: data.length > 1 ? (data.length - 1).toDouble() : 1.0,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 5.0,
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 10, bottom: 5),
                style: TextStyle(
                  fontSize: 9, 
                  color: theme.colorScheme.onSurface.withOpacity(0.3), 
                  fontWeight: FontWeight.bold
                ),
                labelResolver: (_) => 'STABILITY',
              ),
            ),
          ],
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 2,
              getTitlesWidget: (value, meta) {
                String label = '';
                if (value == 0) label = 'AWFUL';
                else if (value == 2) label = 'BAD';
                else if (value == 4) label = 'MEH';
                else if (value == 6) label = 'GOOD';
                else if (value == 8) label = 'GREAT';
                else if (value == 10) label = 'BEST';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 8, 
                      color: theme.colorScheme.onSurface.withOpacity(0.3), 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (value % 1 != 0 || index < 0 || index >= data.length) return const SizedBox.shrink();
                
                int skipCount = (data.length / 5).ceil();
                if (index % skipCount != 0 && index != data.length - 1) return const SizedBox.shrink();

                final date = data[index].date;
                String format = 'MM/dd';
                if (range == MoodRange.last24h) {
                  format = 'HH:mm';
                } else if (range == MoodRange.lastYear) {
                  format = 'MMM yy';
                }

                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    DateFormat(format).format(date),
                    style: TextStyle(
                      fontSize: 10, 
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            barWidth: 5,
            gradient: LinearGradient(
              colors: [AppTheme.terracottaError, AppTheme.sagePrimary],
              stops: [max(0.0, lineStop - 0.1), min(1.0, lineStop + 0.1)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            dotData: FlDotData(
              show: data.length < 20,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: spot.y >= 5.0 ? AppTheme.sagePrimary : AppTheme.terracottaError,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.terracottaError.withOpacity(brightness == Brightness.light ? 0.15 : 0.05),
                  AppTheme.sagePrimary.withOpacity(brightness == Brightness.light ? 0.2 : 0.1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => spot.y < 5.0 ? AppTheme.terracottaError : AppTheme.sagePrimary,
            getTooltipItems: (spots) => spots.map((s) {
              String label = '';
              if (s.y <= 1) label = 'AWFUL';
              else if (s.y <= 3) label = 'BAD';
              else if (s.y <= 5) label = 'MEH';
              else if (s.y <= 7) label = 'GOOD';
              else if (s.y <= 9) label = 'GREAT';
              else label = 'BEST';
              
              final int index = s.x.toInt();
              if (index < 0 || index >= data.length) return null;
              
              final date = data[index].date;
              final String dateStr = range == MoodRange.last24h 
                  ? DateFormat.Hm().format(date) 
                  : range == MoodRange.lastYear
                    ? DateFormat('MMM yyyy').format(date)
                    : DateFormat.yMMMd().format(date);
              
              return LineTooltipItem(
                "$label\n$dateStr",
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final MoodRange selectedRange;
  final Function(MoodRange) onChanged;
  const _RangeSelector({required this.selectedRange, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<MoodRange>(
      initialValue: selectedRange,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLabel(selectedRange),
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
      itemBuilder: (c) => [
        const PopupMenuItem(value: MoodRange.last24h, child: Text("Today")),
        const PopupMenuItem(value: MoodRange.last7d, child: Text("7 Days")),
        const PopupMenuItem(value: MoodRange.last30d, child: Text("30 Days")),
        const PopupMenuItem(value: MoodRange.lastYear, child: Text("Yearly")),
      ],
    );
  }

  String _getLabel(MoodRange r) {
    switch (r) {
      case MoodRange.last24h: return "Today";
      case MoodRange.last7d: return "7d";
      case MoodRange.last30d: return "30d";
      case MoodRange.lastYear: return "Year";
    }
  }
}
