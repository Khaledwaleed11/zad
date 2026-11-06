import 'package:flutter/material.dart';

class HadithDayHeader extends StatelessWidget {
  const HadithDayHeader({super.key});

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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGold),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.auto_awesome,
                size: 17,
                color: gold.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: Icon(
                Icons.auto_awesome,
                size: 17,
                color: gold.withValues(alpha: 0.55),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 20, 17, 18),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lightGold),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 27,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'من هدي النبي ﷺ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'حديث اليوم',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'نور من السنة النبوية يرافق يومك',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: gold.withValues(alpha: 0.65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HadithBookHeader extends StatelessWidget {
  final String bookTitle;

  const HadithBookHeader({super.key, required this.bookTitle});

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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: lightGold),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.auto_awesome,
                color: gold.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Icon(
                Icons.auto_awesome,
                color: gold.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
            Column(
              children: [
                Icon(Icons.menu_book_rounded, color: gold, size: 34),
                const SizedBox(height: 12),
                Text(
                  'من كتب السنة النبوية',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  bookTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 55,
                  height: 2,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
