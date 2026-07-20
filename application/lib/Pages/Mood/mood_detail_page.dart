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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Memory"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded), 
            onPressed: () => _showEditDialog(context),
            tooltip: "Edit Entry",
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            onPressed: () => _confirmDelete(context, moodController, user?.id),
            tooltip: "Delete Entry",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.02), 
                    blurRadius: 40, 
                    offset: const Offset(0, 10)
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(_getEmoji(_currentEntry.value), style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 24),
                  Text(
                    "Mood Level ${_currentEntry.value}",
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d • HH:mm').format(_currentEntry.createdAt),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4), 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 0.5
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            if (_currentEntry.tags != null && _currentEntry.tags!.isNotEmpty) ...[
              _buildSectionTitle(context, "Contextual Tags", Icons.label_outline_rounded),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _currentEntry.tags!.split(',').map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag, 
                    style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)
                  ),
                )).toList(),
              ),
              const SizedBox(height: 40),
            ],
            
            if (_currentEntry.note != null && _currentEntry.note!.isNotEmpty) ...[
              _buildSectionTitle(context, "Your Reflection", Icons.auto_stories_rounded),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                ),
                child: Text(
                  _currentEntry.note!,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.8, fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(), 
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            letterSpacing: 2, 
            fontSize: 11, 
            color: theme.colorScheme.onSurface.withOpacity(0.3)
          )
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, MoodController controller, int? userId) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Remove this reflection?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Keep it")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true && userId != null) {
      await controller.deleteEmotion(_currentEntry.id, userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reflection removed.")));
        Navigator.pop(context);
      }
    }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          title: const Text("Edit Memory"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getEmoji(tempValue.round()), style: const TextStyle(fontSize: 60)),
                Slider(
                  value: tempValue,
                  min: 1, max: 10, divisions: 9,
                  activeColor: AppTheme.sagePrimary,
                  onChanged: (v) => setDialogState(() => tempValue = v),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: moodController.availableTags.map((tag) {
                    final isSelected = tempTags.contains(tag.label);
                    return FilterChip(
                      label: Text(tag.label),
                      selected: isSelected,
                      onSelected: (selected) => setDialogState(() {
                        if (selected) {
                          tempTags.add(tag.label);
                        } else {
                          tempTags.remove(tag.label);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Update your thoughts",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final success = await moodController.updateEmotion(
                  id: _currentEntry.id, userId: user.id, value: tempValue.round(),
                  note: noteController.text, tags: tempTags, createdAt: _currentEntry.createdAt,
                );
                if (success && context.mounted) {
                  setState(() {
                    _currentEntry = _currentEntry.copyWith(
                      value: tempValue.round(),
                      note: Value(noteController.text),
                      tags: Value(tempTags.isEmpty ? null : tempTags.join(',')),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("SAVE CHANGES"),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(int value) {
    final emojis = ['😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'];
    return emojis[(value - 1).clamp(0, 9)];
  }
}
