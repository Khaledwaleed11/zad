import 'package:flutter/material.dart';

class HadithTextCard extends StatelessWidget {
  final String title;
  final String text;

  const HadithTextCard({super.key, required this.title, required this.text});

  IconData _getIcon() {
    switch (title) {
      case 'نص الحديث':
        return Icons.auto_stories_rounded;
      case 'الباب':
        return Icons.bookmark_border_rounded;
      case 'حكم الحديث':
        return Icons.verified_outlined;
      case 'السند':
        return Icons.account_tree_outlined;
      default:
        return Icons.menu_book_rounded;
    }
  }

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
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: gold),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: lightGold),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lightGold),
                  ),
                  child: Icon(_getIcon(), color: gold, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: gold.withValues(alpha: 0.55),
                  size: 17,
                ),
              ],
            ),

            const SizedBox(height: 13),

            Divider(color: lightGold.withValues(alpha: 0.65), thickness: 1),

            const SizedBox(height: 12),

            SelectableText(
              text,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 2,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.content_copy_rounded,
                size: 15,
                color: mutedColor.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
