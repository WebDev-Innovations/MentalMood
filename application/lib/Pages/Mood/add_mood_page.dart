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

  final List<String> _emojis = [
    '😫', '😞', '☹️', '🙁', '😐', '🙂', '😊', '😁', '🤩', '🥳'
  ];

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
          // Calculate precise slot width for 10 emojis
          final double slotWidth = (screenWidth - 32) / _emojis.length;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji Row
                      SizedBox(
                        height: 120, 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_emojis.length, (index) {
                            final int emojiValue = index + 1;
                            final bool isSelected = _currentValue.round() == emojiValue;
                            
                            return SizedBox(
                              width: slotWidth,
                              child: AnimatedScale(
                                // Larger base scale and even larger selected scale
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
                                      style: const TextStyle(fontSize: 32), // Large base font
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
                          inactiveTrackColor: theme.brightness == Brightness.light 
                              ? Colors.black12 
                              : Colors.white10,
                          thumbColor: AppTheme.primarySage,
                          overlayColor: AppTheme.primarySage.withAlpha(32),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 32.0),
                          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                          activeTickMarkColor: AppTheme.primarySage,
                          inactiveTickMarkColor: theme.brightness == Brightness.light 
                              ? Colors.black12 
                              : Colors.white10,
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
                      const SizedBox(height: 80),
                      if (moodController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            moodController.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: ElevatedButton(
                          onPressed: moodController.isLoading
                              ? null
                              : () async {
                                  if (user == null) return;
                                  final success = await moodController.saveMood(
                                    userId: user.id,
                                    value: _currentValue.round(),
                                  );
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Mood saved successfully!"),
                                        backgroundColor: AppTheme.primarySage,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    Navigator.of(context).pop();
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
            ),
          );
        },
      ),
    );
  }
}
