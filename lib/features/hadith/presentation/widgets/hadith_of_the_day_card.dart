import 'package:flutter/material.dart';

import '../../domain/entities/hadith_entity.dart';
import 'hadith_grade_badge.dart';

class HadithOfTheDayCard extends StatelessWidget {
  final HadithEntity hadith;
  final VoidCallback onAnotherHadith;
  final bool isLoading;

  const HadithOfTheDayCard({
    super.key,
    required this.hadith,
    required this.onAnotherHadith,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: lightGold),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: lightGold),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'نص الحديث الشريف',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                HadithGradeBadge(grade: hadith.grade.label),
              ],
            ),

            const SizedBox(height: 18),

            Divider(color: lightGold.withValues(alpha: 0.65), thickness: 1),

            const SizedBox(height: 14),

            Center(
              child: Icon(
                Icons.format_quote_rounded,
                color: gold.withValues(alpha: 0.65),
                size: 34,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hadith.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                height: 2.1,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightGold.withValues(alpha: 0.7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: gold, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hadith.citation,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onAnotherHadith,
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  disabledForegroundColor: mutedColor,
                  side: BorderSide(color: gold.withValues(alpha: 0.7)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: gold,
                        ),
                      )
                    : const Icon(Icons.shuffle_rounded),
                label: Text(
                  isLoading ? 'جاري تحميل حديث آخر...' : 'حديث آخر',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
