import 'package:flutter/material.dart';

import 'qibla_paper_card.dart';

class QiblaHeroHeader extends StatelessWidget {
  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const QiblaHeroHeader({
    super.key,
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
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: lightGold),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: gold,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وَلِكُلٍّ وِجْهَةٌ هُوَ مُوَلِّيهَا',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'اعرف اتجاه القبلة',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'حرّك هاتفك حتى يشير السهم إلى القبلة',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
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