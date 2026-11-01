import 'package:flutter/material.dart';

class AzkarHeader extends StatelessWidget {
  final String categoryTitle;
  final String categoryDescription;

  const AzkarHeader({
    super.key,
    required this.categoryTitle,
    required this.categoryDescription,
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(categoryTitle),
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
                        Icons.favorite_rounded,
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
                            'ذكر الله حياة للقلوب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            categoryTitle,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categoryDescription,
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
      ),
    );
  }
}
