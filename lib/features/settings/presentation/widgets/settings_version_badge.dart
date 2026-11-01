import 'package:flutter/material.dart';

class SettingsVersionBadge extends StatelessWidget {
  final Color gold;

  const SettingsVersionBadge({
    super.key,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: gold.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '1.0.0',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: gold,
        ),
      ),
    );
  }
}