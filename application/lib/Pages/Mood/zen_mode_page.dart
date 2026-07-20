import 'dart:async';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';

enum BreathPhase { ready, countdown, inhale, hold, exhale, finished }

class ZenModePage extends StatefulWidget {
  const ZenModePage({super.key});

  @override
  State<ZenModePage> createState() => _ZenModePageState();
}

class _ZenModePageState extends State<ZenModePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  
  BreathPhase _phase = BreathPhase.ready;
  String _instruction = "Feeling overwhelmed? Let's find your center.";
  int _countdownValue = 3;
  double _phaseProgress = 0.0;
  Timer? _timer;
  Stopwatch _phaseStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Default for inhale
    );

    _sizeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startPanicSequence() {
    setState(() {
      _phase = BreathPhase.countdown;
      _countdownValue = 3;
      _instruction = "Get ready to breathe...";
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
      } else {
        timer.cancel();
        _runBreathingCycle();
      }
    });
  }

  void _runBreathingCycle() async {
    if (!mounted) return;

    // 1. INHALE (4s)
    _startPhase(BreathPhase.inhale, 4, "Breathe in deeply", true);
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted || _phase == BreathPhase.ready) return;

    // 2. HOLD (7s)
    _startPhase(BreathPhase.hold, 7, "Hold your breath", false);
    await Future.delayed(const Duration(seconds: 7));
    if (!mounted || _phase == BreathPhase.ready) return;

    // 3. EXHALE (8s)
    _startPhase(BreathPhase.exhale, 8, "Breathe out slowly", false);
    _controller.reverse(from: 1.0);
    await Future.delayed(const Duration(seconds: 8));
    
    if (mounted && _phase != BreathPhase.ready) {
      _runBreathingCycle(); // Loop
    }
  }

  void _startPhase(BreathPhase phase, int seconds, String instruction, bool animForward) {
    setState(() {
      _phase = phase;
      _instruction = instruction;
      _phaseProgress = 0.0;
    });

    if (animForward) {
      _controller.duration = Duration(seconds: seconds);
      _controller.forward(from: 0.0);
    } else if (phase == BreathPhase.exhale) {
      _controller.duration = Duration(seconds: seconds);
    }

    _phaseStopwatch.reset();
    _phaseStopwatch.start();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _phase == BreathPhase.ready) {
        timer.cancel();
        return;
      }
      setState(() {
        _phaseProgress = (_phaseStopwatch.elapsedMilliseconds / (seconds * 1000)).clamp(0.0, 1.0);
      });
      if (_phaseProgress >= 1.0) timer.cancel();
    });
  }

  void _stop() {
    _timer?.cancel();
    _phaseStopwatch.stop();
    _phaseStopwatch.reset();
    _controller.stop();
    setState(() {
      _phase = BreathPhase.ready;
      _phaseProgress = 0.0;
      _countdownValue = 3;
      _instruction = "You're safe now. Breathe at your own pace.";
    });
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case BreathPhase.inhale: return Colors.blueAccent;
      case BreathPhase.hold: return Colors.purpleAccent;
      case BreathPhase.exhale: return AppTheme.primarySage;
      case BreathPhase.countdown: return Colors.orangeAccent;
      default: return AppTheme.primarySage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColor = _getPhaseColor();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Panic Button"),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Progress Ring + Breathing Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 320,
                  height: 320,
                  child: CircularProgressIndicator(
                    value: _phaseProgress,
                    strokeWidth: 8,
                    color: phaseColor.withOpacity(0.4),
                    backgroundColor: phaseColor.withOpacity(0.05),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 260 * _sizeAnimation.value,
                      height: 260 * _sizeAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: phaseColor.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _phase == BreathPhase.countdown
                          ? Text("$_countdownValue", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.orangeAccent))
                          : Text(
                              _phase == BreathPhase.inhale ? "INHALE" : 
                              _phase == BreathPhase.hold ? "HOLD" : 
                              _phase == BreathPhase.exhale ? "EXHALE" : "READY",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: phaseColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 80),
            
            Text(
              _instruction,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            
            const Spacer(),
            
            if (_phase == BreathPhase.ready)
              ElevatedButton(
                onPressed: _startPanicSequence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  elevation: 8,
                  shadowColor: Colors.redAccent.withOpacity(0.5),
                ),
                child: const Text("I'M OVERWHELMED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              )
            else
              TextButton(
                onPressed: _stop,
                child: Text("STOP SESSION", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
