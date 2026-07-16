import 'dart:math';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Pages/Mood/add_mood_page.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<LoginController>().currentUser;
      if (user != null) {
        final moodController = context.read<MoodController>();
        await moodController.fetchMoodHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.read<LoginController>().currentUser;
    final theme = Theme.of(context);
    final chartData = moodController.getChartData();
    final todayStatus = moodController.getTodayStatus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MentalMood'),
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).pushNamed('/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Seed Mock Data',
            onPressed: () async {
              if (user != null) {
                await context.read<MoodController>().seedMockData(user.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mock data generated for 60 days!")),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Overview",
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (todayStatus['color'] as Color).withAlpha(20),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: (todayStatus['color'] as Color).withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Text(
                      todayStatus['emoji'],
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayStatus['label'],
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: todayStatus['color'] as Color,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moodController.getTodayAverage() != null
                                ? "Daily average: ${moodController.getTodayAverage()!.toStringAsFixed(1)}/10"
                                : "No mood recorded yet today",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                "Your Mood Journey",
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                moodController.getMoodSummary(),
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primarySage),
              ),
              const SizedBox(height: 24),
              
              _RangeSelector(
                selectedRange: moodController.selectedRange,
                onChanged: (range) => moodController.setSelectedRange(range),
              ),
              
              const SizedBox(height: 24),
              
              Container(
                height: 280,
                width: double.infinity,
                padding: const EdgeInsets.only(right: 24, top: 24, bottom: 12, left: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(theme.brightness == Brightness.light ? 8 : 40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: chartData.isEmpty
                    ? const Center(child: Text("Not enough data for this range"))
                    : _MoodLineChart(data: chartData, range: moodController.selectedRange),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMoodPage()),
          );
        },
        backgroundColor: AppTheme.primarySage,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, size: 32),
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
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RangeButton(
              label: "24h",
              isSelected: selectedRange == MoodRange.last24h,
              onTap: () => onChanged(MoodRange.last24h),
            ),
            _RangeButton(
              label: "7d",
              isSelected: selectedRange == MoodRange.last7d,
              onTap: () => onChanged(MoodRange.last7d),
            ),
            _RangeButton(
              label: "30d",
              isSelected: selectedRange == MoodRange.last30d,
              onTap: () => onChanged(MoodRange.last30d),
            ),
            _RangeButton(
              label: "Year",
              isSelected: selectedRange == MoodRange.lastYear,
              onTap: () => onChanged(MoodRange.lastYear),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySage : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
              ? Colors.white 
              : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MoodLineChart extends StatelessWidget {
  final List<ChartMoodPoint> data;
  final MoodRange range;

  const _MoodLineChart({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    final double minYData = data.map((e) => e.value).reduce(min);
    final double maxYData = data.map((e) => e.value).reduce(max);
    
    double lineStop = 0.5;
    if (maxYData != minYData) {
      lineStop = (5.0 - minYData) / (maxYData - minYData);
    } else {
      lineStop = maxYData >= 5.0 ? 0.0 : 1.0;
    }
    lineStop = lineStop.clamp(0.0, 1.0);

    double bgStop = 1.0;
    if (maxYData > 0) {
      bgStop = 5.0 / maxYData;
    }
    bgStop = bgStop.clamp(0.0, 1.0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 5.0,
              color: Colors.grey.withAlpha(100),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 10, bottom: 5),
                style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                labelResolver: (_) => 'STABILITY',
              ),
            ),
          ],
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.black.withAlpha(10),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                
                final date = data[index].date;
                String text = '';
                if (range == MoodRange.last24h) {
                  text = DateFormat.Hm().format(date);
                } else if (range == MoodRange.lastYear) {
                  text = DateFormat.MMM().format(date);
                } else {
                  text = DateFormat.Md().format(date);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70,
              interval: 2,
              getTitlesWidget: (value, meta) {
                String label = '';
                if (value == 0) label = 'VERY BAD';
                else if (value == 2) label = 'BAD';
                else if (value == 4) label = 'MEH';
                else if (value == 6) label = 'GOOD';
                else if (value == 8) label = 'GREAT';
                else if (value == 10) label = 'EXCELLENT';

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index].value)),
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: LinearGradient(
              colors: const [Colors.redAccent, AppTheme.primarySage],
              stops: [max(0.0, lineStop - 0.1), min(1.0, lineStop + 0.1)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length < 20,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: spot.y >= 5.0 ? AppTheme.primarySage : Colors.redAccent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.redAccent.withAlpha(brightness == Brightness.light ? 40 : 20),
                  AppTheme.primarySage.withAlpha(brightness == Brightness.light ? 60 : 30),
                ],
                stops: [max(0.0, bgStop - 0.05), min(1.0, bgStop + 0.05)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineChartData().lineTouchData.copyWith(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => touchedSpot.y < 5.0 ? Colors.redAccent : AppTheme.primarySage,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final point = data[spot.x.toInt()];
              String dateStr = range == MoodRange.lastYear 
                  ? DateFormat.yMMMM().format(point.date)
                  : DateFormat.yMd().add_Hm().format(point.date);
              return LineTooltipItem(
                '${point.value.toStringAsFixed(1)}\n$dateStr',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList(),
          ),
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) => spotIndexes.map((index) {
            final y = barData.spots[index].y;
            final color = y < 5.0 ? Colors.redAccent : AppTheme.primarySage;
            return TouchedSpotIndicatorData(
              FlLine(color: color, strokeWidth: 4),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: color,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getInterval() {
    if (data.length <= 5) return 1;
    return (data.length / 4).floorToDouble();
  }
}
