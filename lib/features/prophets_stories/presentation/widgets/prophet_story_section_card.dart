import 'package:flutter/material.dart';

import '../../domain/entities/prophet_story_section_entity.dart';

class ProphetStorySectionCard extends StatelessWidget {
  final ProphetStorySectionEntity section;
  final VoidCallback onTap;

  const ProphetStorySectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);
    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);
    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);
    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);
    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);
    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: gold, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.04 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: innerPaper,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: lightGold.withValues(alpha: 0.8)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: gold,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'قصص الأنبياء لابن كثير • ${section.volumeTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
