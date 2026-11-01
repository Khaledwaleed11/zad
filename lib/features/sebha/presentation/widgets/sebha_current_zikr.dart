import 'dart:math' as math;

import 'package:flutter/material.dart';

class SebhaCurrentZikr extends StatelessWidget {
  final String zikr;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const SebhaCurrentZikr({
    super.key,
    required this.zikr,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _paperCard(
        radius: 21,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 19,
        ),
        child: Column(
          children: [
            Text(
              'الذكر الحالي',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              zikr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                height: 1.45,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 2,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paperCard({
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
          color: innerPaper,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.55),
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
                angle: math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi,
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