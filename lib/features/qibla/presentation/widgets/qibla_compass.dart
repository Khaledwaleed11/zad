import 'dart:math' as math;

import 'package:flutter/material.dart';

class QiblaCompass extends StatelessWidget {
  final double rotation;

  const QiblaCompass({super.key, required this.rotation});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 300,
      height: 300,

      child: Stack(
        alignment: Alignment.center,

        children: [
          Container(
            width: 300,
            height: 300,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: colors.surface,

              border: Border.all(
                color: colors.primary.withValues(alpha: 0.15),
                width: 2,
              ),

              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          AnimatedRotation(
            turns: rotation / 360,
            duration: const Duration(milliseconds: 350),

            curve: Curves.easeOut,

            child: SizedBox(
              width: 265,
              height: 265,

              child: CustomPaint(painter: _CompassPainter(colors: colors)),
            ),
          ),

          Container(
            width: 72,
            height: 72,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: colors.primary,

              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
              ],
            ),

            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          Positioned(
            top: 9,

            child: Icon(
              Icons.navigation_rounded,
              size: 27,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final ColorScheme colors;

  _CompassPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2;

    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: colors.onSurface,
    );

    _drawDirection(
      canvas,
      'N',
      center,
      radius - 27,
      -math.pi / 2,
      textStyle.copyWith(color: colors.error),
    );

    _drawDirection(canvas, 'E', center, radius - 27, 0, textStyle);

    _drawDirection(canvas, 'S', center, radius - 27, math.pi / 2, textStyle);

    _drawDirection(canvas, 'W', center, radius - 27, math.pi, textStyle);

    final paint = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1.3;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * math.pi / 180;

      final startRadius = i % 3 == 0 ? radius - 22 : radius - 16;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );

      final end = Offset(
        center.dx + math.cos(angle) * (radius - 9),
        center.dy + math.sin(angle) * (radius - 9),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  void _drawDirection(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double angle,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final position = Offset(
      center.dx + math.cos(angle) * radius - textPainter.width / 2,
      center.dy + math.sin(angle) * radius - textPainter.height / 2,
    );

    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
