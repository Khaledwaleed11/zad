import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final Widget child;
  final Color gold;
  final Color innerPaper;
  final Color lightGold;
  final EdgeInsetsGeometry padding;
  final double radius;

  const SettingsGroup({
    super.key,
    required this.child,
    required this.gold,
    required this.innerPaper,
    required this.lightGold,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius + 3),
        border: Border.all(
          color: gold.withValues(alpha: 0.75),
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