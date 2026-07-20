import 'package:flutter/material.dart';

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final int duration;
  final Offset direction;
  final Curve curve;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = 600,
    this.direction = const Offset(0, 20),
    this.curve = Curves.easeOutQuart,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: duration),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: direction * (1.0 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ScaleIn extends StatelessWidget {
  final Widget child;
  final int duration;
  final int delay;

  const ScaleIn({
    super.key,
    required this.child,
    this.duration = 500,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: duration),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }
}

class HoverEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  
  const HoverEffect({
    super.key, 
    required this.child, 
    this.scale = 1.02,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack, // Gives a slight "pop" feel
        alignment: Alignment.center, // Explicitly centered
        child: widget.child,
      ),
    );
  }
}
