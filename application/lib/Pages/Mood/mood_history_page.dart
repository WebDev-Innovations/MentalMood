import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Pages/Mood/mood_detail_page.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});

  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  String _searchText = '';
  bool _isFilterExpanded = false;
  RangeValues _scoreRange = const RangeValues(1, 10);
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final theme = Theme.of(context);
    
    final history = moodController.moodHistory.where((e) {
      final textMatch = _searchText.isEmpty || 
          (e.note?.toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
          (e.tags?.toLowerCase().contains(_searchText.toLowerCase()) ?? false);
      final scoreMatch = e.value >= _scoreRange.start && e.value <= _scoreRange.end;
      final tagsFilterMatch = _selectedTags.isEmpty || 
          (_selectedTags.every((tag) => e.tags?.contains(tag) ?? false));
      return textMatch && scoreMatch && tagsFilterMatch;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Journal History"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFilterExpanded ? Icons.filter_list_off_rounded : Icons.filter_list_rounded),
            onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchText = v),
              decoration: InputDecoration(
                hintText: "Search your reflections...",
                prefixIcon: const Icon(Icons.search_rounded),
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          if (_isFilterExpanded) _buildFilterPanel(context, moodController),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final user = context.read<LoginController>().currentUser;
                if (user != null) {
                  await moodController.fetchMoodHistory(user.id);
                }
              },
              color: AppTheme.sagePrimary,
              backgroundColor: theme.colorScheme.surface,
              child: history.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildEmptyState(context),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      clipBehavior: Clip.none, // Allow hover scale without clipping
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return FadeInSlide(
                          duration: 300 + (index * 50).clamp(0, 500),
                          direction: const Offset(20, 0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: HoverEffect(
                              scale: 1.02,
                              child: _JournalEntryTile(entry: entry),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, MoodController controller) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.02), 
            blurRadius: 40, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SCORE RANGE", 
                style: TextStyle(
                  fontWeight: FontWeight.w800, 
                  letterSpacing: 1, 
                  fontSize: 11, 
                  color: theme.colorScheme.onSurface.withOpacity(0.4)
                )
              ),
              Text(
                "${_scoreRange.start.round()} - ${_scoreRange.end.round()}", 
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          RangeSlider(
            values: _scoreRange,
            min: 1, max: 10, divisions: 9,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => setState(() => _scoreRange = v),
          ),
          const SizedBox(height: 16),
          Text(
            "FILTER BY TAGS", 
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              letterSpacing: 1, 
              fontSize: 11, 
              color: theme.colorScheme.onSurface.withOpacity(0.4)
            )
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag.label);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(tag.label, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag.label);
                        } else {
                          _selectedTags.remove(tag.label);
                        }
                      });
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            "Your history is quiet.", 
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}

class _JournalEntryTile extends StatelessWidget {
  final dynamic entry;
  const _JournalEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('MMMM d').format(entry.createdAt);
    final time = DateFormat.Hm().format(entry.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.1 : 0.01), 
            blurRadius: 20, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MoodDetailPage(entry: entry))),
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getEmotionColor(entry.value).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(entry.value), 
                    style: const TextStyle(fontSize: 32)
                  )
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Text(
                          time, 
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 12)
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Text(
                        entry.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.4, fontSize: 13),
                      )
                    else
                      Text(
                        "Mood level ${entry.value}", 
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 13)
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.1)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEmotionColor(int value) {
    if (value <= 3) return AppTheme.terracottaError;
    if (value <= 6) return AppTheme.sagePrimary;
    return AppTheme.oliveSecondary;
  }

  String _getEmoji(int value) {
    final emojis = ['😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'];
    return emojis[(value - 1).clamp(0, 9)];
  }
}
