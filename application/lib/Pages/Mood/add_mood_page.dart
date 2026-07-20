import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/theme.dart';
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

  final List<String> _emojis = [
    '😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _showAddTagDialog(BuildContext context, MoodController controller, int userId) {
    final labelController = TextEditingController();
    final emojiController = TextEditingController(text: '🏷️');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Tag"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose an icon and a name for your tag.", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: emojiController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Emoji",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: "Tag Name",
                      hintText: "e.g. Reading",
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.isNotEmpty) {
                controller.addCustomTag(labelController.text, emojiController.text, userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Tag '${labelController.text}' created!"),
                      backgroundColor: AppTheme.primarySage,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("CREATE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.read<LoginController>().currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("How are you?"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double slotWidth = (screenWidth - 32) / _emojis.length;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  children: [
                    // Emoji Row
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_emojis.length, (index) {
                          final int emojiValue = index + 1;
                          final bool isSelected = _currentValue.round() == emojiValue;
                          
                          return SizedBox(
                            width: slotWidth,
                            child: AnimatedScale(
                              scale: isSelected ? 1.8 : 1.1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              child: ColorFiltered(
                                colorFilter: isSelected 
                                  ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                  : const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0,      0,      0,      1, 0,
                                    ]),
                                child: AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.5,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: Text(
                                    _emojis[index],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Custom Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        activeTrackColor: AppTheme.primarySage,
                        thumbColor: AppTheme.primarySage,
                        overlayColor: AppTheme.primarySage.withAlpha(32),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                      ),
                      child: Slider(
                        value: _currentValue,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) {
                          setState(() {
                            _currentValue = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Tags Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("What's influencing your mood?", style: theme.textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.primarySage),
                          onPressed: user != null ? () => _showAddTagDialog(context, moodController, user.id) : null,
                          tooltip: "Add Custom Tag",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moodController.availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag.label);
                        return FilterChip(
                          label: Text("${tag.emoji} ${tag.label}"),
                          selected: isSelected,
                          onSelected: (_) => _toggleTag(tag.label),
                          selectedColor: AppTheme.primarySage.withAlpha(50),
                          checkmarkColor: AppTheme.primarySage,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primarySage : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Note Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Add a note (optional)", style: theme.textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write how you feel...",
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primarySage, width: 2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    if (moodController.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          moodController.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Mood saved successfully!"),
                                      backgroundColor: AppTheme.primarySage,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );

                                  // Check if mood is low (<= 3) to suggest Zen Mode
                                  if (_currentValue.round() <= 3) {
                                    _showZenModeSuggestion(context);
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                        child: moodController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("SAVE MOOD"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showZenModeSuggestion(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 12),
            Text("Panic Support"),
          ],
        ),
        content: const Text(
          "It seems like you're feeling very overwhelmed. Would you like to use the Panic Button for an immediate breathing exercise?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); 
              Navigator.pop(context); 
            },
            child: const Text("NOT NOW", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/zen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("ACTIVATE PANIC BUTTON"),
          ),
        ],
      ),
    );
  }
}
