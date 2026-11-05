import 'package:flutter/material.dart';

class AnimatedAyahCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const AnimatedAyahCard({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double delay = (index * 0.03).clamp(0.0, 0.35);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double value = ((controller.value - delay) / (1 - delay)).clamp(
          0.0,
          1.0,
        );

        final curved = Curves.easeOutCubic.transform(value);

        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curved)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
