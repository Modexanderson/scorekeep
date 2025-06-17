// widgets/animated_background.dart
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).primaryColor.withOpacity(0.05),
                Theme.of(context).colorScheme.secondary.withOpacity(0.03),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: [
                0.0,
                0.3 + (_controller.value * 0.4),
                0.7 + (_controller.value * 0.3),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
