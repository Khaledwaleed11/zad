
import 'package:flutter/material.dart';

import '../../domain/entities/hadith_search_result_entity.dart';

class HadithSearchResultCard extends StatelessWidget {
  final HadithSearchResultEntity hadith;
  final VoidCallback onTap;

  const HadithSearchResultCard({
    super.key,
    required this.hadith,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final goldColor = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: isDark ? 0.04 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: goldColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'نتيجة البحث',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  hadith.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(
                  color: goldColor.withValues(alpha: 0.25),
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 16,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        hadith.citation,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: goldColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
