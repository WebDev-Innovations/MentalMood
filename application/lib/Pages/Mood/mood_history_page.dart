import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Pages/Mood/mood_detail_page.dart';
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
      final noteMatch = e.note?.toLowerCase().contains(_searchText.toLowerCase()) ?? false;
      final tagsMatch = e.tags?.toLowerCase().contains(_searchText.toLowerCase()) ?? false;
      final textMatch = _searchText.isEmpty || noteMatch || tagsMatch;
      final scoreMatch = e.value >= _scoreRange.start && e.value <= _scoreRange.end;

      bool tagsFilterMatch = true;
      if (_selectedTags.isNotEmpty) {
        if (e.tags == null) {
          tagsFilterMatch = false;
        } else {
          final entryTags = e.tags!.split(',');
          tagsFilterMatch = _selectedTags.every((tag) => entryTags.contains(tag));
        }
      }
      return textMatch && scoreMatch && tagsFilterMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood History"),
        actions: [
          IconButton(
            icon: Icon(_isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isFilterExpanded ? 240 : 70),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search notes or tags...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) => setState(() => _searchText = value),
                ),
              ),
              if (_isFilterExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Mood Score: ${_scoreRange.start.round()} - ${_scoreRange.end.round()}", style: theme.textTheme.bodySmall),
                          TextButton(
                            onPressed: () => setState(() { _scoreRange = const RangeValues(1, 10); _selectedTags.clear(); }),
                            child: const Text("Reset", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _scoreRange,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppTheme.primarySage,
                        onChanged: (values) => setState(() => _scoreRange = values),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: moodController.availableTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag.label);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text("${tag.emoji} ${tag.label}", style: const TextStyle(fontSize: 12)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) _selectedTags.add(tag.label);
                                    else _selectedTags.remove(tag.label);
                                  });
                                },
                                selectedColor: AppTheme.primarySage.withOpacity(0.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: history.isEmpty
          ? const Center(child: Text("No entries found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Text(_getEmojiForValue(entry.value), style: const TextStyle(fontSize: 32)),
                    title: Text("Score: ${entry.value}/10", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat.yMMMMd().add_Hm().format(entry.createdAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MoodDetailPage(entry: entry)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  String _getEmojiForValue(int value) {
    final emojis = ['😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'];
    return emojis[(value - 1).clamp(0, 9)];
  }
}
