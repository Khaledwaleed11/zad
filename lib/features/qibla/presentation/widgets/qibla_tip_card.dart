import 'package:flutter/material.dart';

import 'qibla_paper_card.dart';

class QiblaTipCard extends StatelessWidget {
  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color mutedColor;

  const QiblaTipCard({
    super.key,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
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
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'للحصول على قراءة أدق، أبعد الهاتف عن المعادن والأجهزة الإلكترونية وحافظ عليه بشكل أفقي أثناء تحديد الاتجاه.',
              style: TextStyle(
                fontSize: 11,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}