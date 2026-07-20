import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/theme.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoodDetailPage extends StatefulWidget {
  final EmotionData entry;

  const MoodDetailPage({super.key, required this.entry});

  @override
  State<MoodDetailPage> createState() => _MoodDetailPageState();
}

class _MoodDetailPageState extends State<MoodDetailPage> {
  late EmotionData _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodController = context.read<MoodController>();
    final user = context.read<LoginController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context),
            tooltip: "Edit Entry",
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Entry?"),
                  content: const Text("This action cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && user != null) {
                await moodController.deleteEmotion(_currentEntry.id, user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Entry deleted successfully"),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: _getColorForValue(_currentEntry.value).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: _getColorForValue(_currentEntry.value).withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Text(_getEmojiForValue(_currentEntry.value), style: const TextStyle(fontSize: 64)),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Score: ${_currentEntry.value}/10",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getColorForValue(_currentEntry.value),
                          ),
                        ),
                        Text(
                          _getLabelForValue(_currentEntry.value),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _getColorForValue(_currentEntry.value).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(context, "Time & Date", DateFormat.yMMMMEEEEd().add_Hm().format(_currentEntry.createdAt), Icons.calendar_today_rounded),
            const SizedBox(height: 24),
            if (_currentEntry.tags != null && _currentEntry.tags!.isNotEmpty) ...[
              Text("Influenced by", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentEntry.tags!.split(',').map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: theme.cardColor,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                )).toList(),
              ),
              const SizedBox(height: 32),
            ],
            if (_currentEntry.note != null && _currentEntry.note!.isNotEmpty) ...[
              Text("Notes", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
                child: Text(_currentEntry.note!, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final moodController = context.read<MoodController>();
    final user = context.read<LoginController>().currentUser;
    if (user == null) return;

    final noteController = TextEditingController(text: _currentEntry.note);
    double tempValue = _currentEntry.value.toDouble();
    List<String> tempTags = _currentEntry.tags?.split(',').where((t) => t.isNotEmpty).toList() ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Entry"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(_getEmojiForValue(tempValue.round()), style: const TextStyle(fontSize: 48)),
                ),
                Slider(
                  value: tempValue,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppTheme.primarySage,
                  onChanged: (v) => setDialogState(() => tempValue = v),
                ),
                const SizedBox(height: 16),
                const Text("Influenced by:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moodController.availableTags.map((tag) {
                        final isSelected = tempTags.contains(tag.label);
                        return FilterChip(
                          label: Text("${tag.emoji} ${tag.label}", style: const TextStyle(fontSize: 13)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                tempTags.add(tag.label);
                              } else {
                                tempTags.remove(tag.label);
                              }
                            });
                          },
                          selectedColor: AppTheme.primarySage.withOpacity(0.2),
                          checkmarkColor: AppTheme.primarySage,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(hintText: "Add a note..."),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            TextButton(
              onPressed: () async {
                final success = await moodController.updateEmotion(
                  id: _currentEntry.id,
                  userId: user.id,
                  value: tempValue.round(),
                  note: noteController.text,
                  tags: tempTags,
                  createdAt: _currentEntry.createdAt,
                );
                if (success && context.mounted) {
                  setState(() {
                    _currentEntry = _currentEntry.copyWith(
                      value: tempValue.round(),
                      note: Value(noteController.text),
                      tags: Value(tempTags.isEmpty ? null : tempTags.join(',')),
                    );
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Entry updated successfully"),
                        backgroundColor: AppTheme.primarySage,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("SAVE"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primarySage),
            const SizedBox(width: 12),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }

  Color _getColorForValue(int value) {
    if (value <= 3) return Colors.redAccent;
    if (value <= 6) return Colors.blueAccent;
    if (value <= 8) return AppTheme.primarySage;
    return Colors.orange;
  }

  String _getEmojiForValue(int value) {
    final emojis = ['😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'];
    return emojis[(value - 1).clamp(0, 9)];
  }

  String _getLabelForValue(int value) {
    if (value <= 2.5) return "Tough Day";
    if (value <= 4.5) return "Bit Rough";
    if (value <= 6.5) return "Steady";
    if (value <= 8.5) return "Good Day";
    return "Fantastic!";
  }
}
