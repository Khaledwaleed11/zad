import 'package:flutter/material.dart';

class HadithStatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color goldColor;
  final Color textColor;
  final Color mutedColor;

  const HadithStatusMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.goldColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: goldColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: goldColor, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 13, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
