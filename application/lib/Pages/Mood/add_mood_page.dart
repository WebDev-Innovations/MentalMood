import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddMoodPage extends StatefulWidget {
  const AddMoodPage({super.key});

  @override
  State<AddMoodPage> createState() => _AddMoodPageState();
}

class _AddMoodPageState extends State<AddMoodPage> {
  double _currentValue = 5.0;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _emojis = ['😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'];
  final List<String> _labels = ['Awful', 'Sad', 'Bad', 'Meh', 'Okay', 'Good', 'Happy', 'Great', 'Awesome', 'Fantastic!'];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.read<LoginController>().currentUser;
    final theme = Theme.of(context);
    final int index = (_currentValue.round() - 1).clamp(0, 9);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("How are you?"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  _emojis[index],
                  style: const TextStyle(fontSize: 120),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "I feel ${_labels[index]}",
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 60),
            
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 20,
                activeTrackColor: theme.colorScheme.primary.withOpacity(0.8),
                inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.1),
                thumbColor: theme.colorScheme.surface,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 22, elevation: 8),
                trackShape: const RoundedRectSliderTrackShape(),
                overlayColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Slider(
                value: _currentValue,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _currentValue = v),
              ),
            ),
            
            const SizedBox(height: 80),
            
            _buildHeader(context, "Context", Icons.bubble_chart_rounded),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...moodController.availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag.label);
                  return FilterChip(
                    label: Text("${tag.emoji} ${tag.label}"),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag.label),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                    checkmarkColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.05)),
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  );
                }),
                ActionChip(
                  label: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () => _showAddTagDialog(context, moodController, user!.id),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            
            const SizedBox(height: 56),
            
            _buildHeader(context, "Journal Entry", Icons.notes_rounded),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "What happened today?",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                fillColor: theme.colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 60),
            
            ElevatedButton(
              onPressed: moodController.isLoading
                  ? null
                  : () async {
                      if (user == null) return;
                      final success = await moodController.saveMood(
                        userId: user.id,
                        value: _currentValue.round(),
                        note: _noteController.text.isNotEmpty ? _noteController.text : null,
                        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
                      );
                      if (success && mounted) {
                        if (_currentValue.round() <= 3) {
                          _showPanicSuggestion(context);
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
              child: moodController.isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SAVE MY CHECK-IN"),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 8),
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

  void _showAddTagDialog(BuildContext context, MoodController controller, int userId) {
    final theme = Theme.of(context);
    final labelController = TextEditingController();
    final emojiController = TextEditingController(text: '🏷️');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text("New Personal Tag"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emojiController, decoration: const InputDecoration(labelText: "Icon / Emoji")),
            const SizedBox(height: 16),
            TextField(controller: labelController, decoration: const InputDecoration(labelText: "Name")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.isNotEmpty) {
                controller.addCustomTag(labelController.text, emojiController.text, userId);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 56)),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showPanicSuggestion(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text("Breathe with us?"),
        content: const Text("Your mood level is quite low. Would you like to use the Panic Button for a guided session?"),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("Not now")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/zen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes, help me"),
          ),
        ],
      ),
    );
  }
}
