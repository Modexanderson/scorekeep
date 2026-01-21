// widgets/score_button.dart (FIXED VERSION)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScoreButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isEnabled;

  const ScoreButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.isEnabled = true,
  });

  @override
  State<ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<ScoreButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late Animation<double> _pressAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // FIX: Clamp animation values to prevent overflow
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressAnimation, _rippleAnimation]),
        builder: (context, child) {
          final clampedPress = _pressAnimation.value.clamp(0.0, 1.0);
          final clampedRipple = _rippleAnimation.value.clamp(0.0, 1.0);

          return Transform.scale(
            scale: clampedPress,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (clampedRipple > 0)
                  Container(
                    width: 60 * (1 + clampedRipple),
                    height: 60 * (1 + clampedRipple),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.color.withOpacity(0.3 * (1 - clampedRipple)),
                    ),
                  ),
                // Main button
                GestureDetector(
                  onTapDown: widget.isEnabled
                      ? (_) => _pressController.forward()
                      : null,
                  onTapUp: widget.isEnabled
                      ? (_) {
                          _pressController.reverse();
                          _rippleController
                              .forward()
                              .then((_) => _rippleController.reset());
                          HapticFeedback.lightImpact();
                          widget.onPressed();
                        }
                      : null,
                  onTapCancel: widget.isEnabled
                      ? () => _pressController.reverse()
                      : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isEnabled
                          ? LinearGradient(
                              colors: [
                                widget.color,
                                widget.color.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: widget.isEnabled ? null : Colors.grey,
                      boxShadow: widget.isEnabled
                          ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
