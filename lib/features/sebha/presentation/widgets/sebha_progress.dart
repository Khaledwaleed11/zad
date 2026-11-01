import 'package:flutter/material.dart';

class SebhaProgress extends StatelessWidget {
  final int count;
  final int target;
  final double progress;
  final int remaining;
  final bool isCompleted;

  final Color gold;
  final Color textColor;
  final Color mutedColor;

  const SebhaProgress({
    super.key,
    required this.count,
    required this.target,
    required this.progress,
    required this.remaining,
    required this.isCompleted,
    required this.gold,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return _paperCard(
      context: context,
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.trending_up_rounded,
                color: gold,
                size: 18,
              ),
              const SizedBox(width: 7),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  isCompleted ? 'تم إكمال الهدف ✓' : 'التقدم',
                  key: ValueKey(isCompleted),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? gold : textColor,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  '$count / $target',
                  key: ValueKey(count),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: gold.withValues(alpha: 0.13),
                  color: gold,
                ),
              );
            },
          ),
          const SizedBox(height: 11),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isCompleted
                  ? 'ما شاء الله، تم بحمد الله'
                  : 'متبقي $remaining مرة',
              key: ValueKey(isCompleted ? 'done' : remaining),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paperCard({
    required BuildContext context,

    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius + 3),
        border: Border.all(
          color: gold.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF201B13)
              : const Color(0xFFFFFCF4),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF806B43)
                : const Color(0xFFD6BE83))
                .withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: _cornerDecoration(),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Transform.rotate(
                angle: 1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: 3.1416,
                child: _cornerDecoration(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: gold.withValues(alpha: 0.65),
    );
  }
}