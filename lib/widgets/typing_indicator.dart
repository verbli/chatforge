import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color backgroundColor;
  final Color dotColor;
  final double size;
  final Duration animationDuration;

  const TypingIndicator({
    super.key,
    this.backgroundColor = const Color(0xFF3B3B3B),
    this.dotColor = Colors.white,
    this.size = 8.0,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}
class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Create three overlapping animations
    _animations = List.generate(3, (index) {
      // Each animation starts at a different point but overlaps with the next
      final startPercent = index * 0.2;
      final peakPercent = startPercent + 0.2;
      final endPercent = startPercent + 0.4;

      return TweenSequence<double>([
        // Rise up
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        // Fall down
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startPercent,
            endPercent,
            curve: Curves.linear,
          ),
        ),
      );
    });

    // Start the repeating animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -6 * _animations[index].value),  // Increased range of motion
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.dotColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}