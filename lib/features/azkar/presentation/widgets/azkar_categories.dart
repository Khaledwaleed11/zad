import 'package:flutter/material.dart';

class AzkarCategories extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const AzkarCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryChip(context, title: 'أذكار الصباح', value: 'morning'),
          _buildCategoryChip(context, title: 'أذكار المساء', value: 'evening'),
          _buildCategoryChip(context, title: 'أذكار النوم', value: 'sleep'),
          _buildCategoryChip(context, title: 'أذكاري', value: 'custom'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final isSelected = selectedCategory == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const gold = Color(0xFFA88746);
    const lightGold = Color(0xFFD6BE83);

    final selectedColor = isDark ? const Color(0xFFD6BE83) : gold;

    final unselectedColor = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFFFFCF4);

    final textColor = isSelected
        ? (isDark ? const Color(0xFF201B13) : Colors.white)
        : (isDark ? const Color(0xFFF2E8D2) : const Color(0xFF786548));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : lightGold,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCategoryChanged(value),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value == 'morning'
                        ? Icons.wb_sunny_outlined
                        : value == 'evening'
                        ? Icons.nights_stay_outlined
                        : value == 'sleep'
                        ? Icons.bedtime_outlined
                        : Icons.bookmark_outline_rounded,
                    size: 17,
                    color: textColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
