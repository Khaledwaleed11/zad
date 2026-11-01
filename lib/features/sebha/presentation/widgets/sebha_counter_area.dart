import 'package:flutter/material.dart';

import 'sebha_counter.dart';

class SebhaCounterArea extends StatelessWidget {
  final Animation<double> tapAnimation;
  final Animation<double> ambientAnimation;
  final Animation<double> completionAnimation;

  final bool isCompleted;
  final int count;
  final int target;
  final Color gold;

  final VoidCallback onTap;
  final VoidCallback onReset;

  const SebhaCounterArea({
    super.key,
    required this.tapAnimation,
    required this.ambientAnimation,
    required this.completionAnimation,
    required this.isCompleted,
    required this.count,
    required this.target,
    required this.gold,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        tapAnimation,
        ambientAnimation,
        completionAnimation,
      ]),
      builder: (context, child) {
        final tapScale = 1 - (tapAnimation.value * 0.035);

        final completionScale = isCompleted
            ? 1 + (completionAnimation.value * 0.025)
            : 1.0;

        final glow = 0.05 + (ambientAnimation.value * 0.035);

        return Transform.scale(
          scale: tapScale * completionScale,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: gold.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(
                    alpha: isCompleted
                        ? 0.16 + (completionAnimation.value * 0.09)
                        : glow,
                  ),
                  blurRadius: isCompleted ? 32 : 22,
                  spreadRadius: isCompleted ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: SebhaCounter(
                count: count,
                target: target,
                onTap: onTap,
                onReset: onReset,
              ),
            ),
          ),
        );
      },
    );
  }
}