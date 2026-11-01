import 'package:flutter/material.dart';
import 'package:zad/core/constants/app_constants.dart';

class SettingsFooter extends StatelessWidget {
  final Color gold;
  final Color mutedColor;

  const SettingsFooter({
    super.key,
    required this.gold,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: gold.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 27,
            color: gold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: gold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'زادك في طريقك إلى الله',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 55,
          height: 3,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}