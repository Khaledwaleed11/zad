import 'package:flutter/material.dart';

import 'qibla_paper_card.dart';

class QiblaInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const QiblaInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return QiblaPaperCard(
      isDark: isDark,
      paper: paper,
      innerPaper: innerPaper,
      gold: gold,
      lightGold: lightGold,
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lightGold.withValues(alpha: 0.8)),
            ),
            child: Icon(icon, size: 18, color: gold),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
