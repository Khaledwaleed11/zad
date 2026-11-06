import 'package:flutter/material.dart';

class DuaFilters extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDark;
  final bool isFavoritesSelected;
  final String selectedCategoryName;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;
  final Color paper;
  final Color innerPaper;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onCategoryTap;

  const DuaFilters({
    super.key,
    required this.searchController,
    required this.isDark,
    required this.isFavoritesSelected,
    required this.selectedCategoryName,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
    required this.paper,
    required this.innerPaper,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DuaSearchField(
          controller: searchController,
          isDark: isDark,
          gold: gold,
          lightGold: lightGold,
          textColor: textColor,
          mutedColor: mutedColor,
          paper: paper,
          innerPaper: innerPaper,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        _DuaCategorySelector(
          isFavoritesSelected: isFavoritesSelected,
          selectedCategoryName: selectedCategoryName,
          isDark: isDark,
          gold: gold,
          lightGold: lightGold,
          textColor: textColor,
          mutedColor: mutedColor,
          paper: paper,
          innerPaper: innerPaper,
          onTap: onCategoryTap,
        ),
      ],
    );
  }
}

class _DuaSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;
  final Color paper;
  final Color innerPaper;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _DuaSearchField({
    required this.controller,
    required this.isDark,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
    required this.paper,
    required this.innerPaper,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: isDark ? 0.06 : 0.11),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: lightGold.withValues(alpha: 0.8)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: innerPaper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightGold.withValues(alpha: 0.25)),
            ),
            child: Stack(
              children: [
                ...[
                  Alignment.topRight,
                  Alignment.topLeft,
                  Alignment.bottomRight,
                  Alignment.bottomLeft,
                ].map(
                  (alignment) => Align(
                    alignment: alignment,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: gold.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن دعاء...',
                      hintStyle: TextStyle(color: mutedColor),
                      prefixIcon: Icon(Icons.search_rounded, color: gold),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: onClear,
                              icon: Icon(Icons.close, color: mutedColor),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DuaCategorySelector extends StatelessWidget {
  final bool isFavoritesSelected;
  final String selectedCategoryName;
  final bool isDark;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;
  final Color paper;
  final Color innerPaper;
  final VoidCallback onTap;

  const _DuaCategorySelector({
    required this.isFavoritesSelected,
    required this.selectedCategoryName,
    required this.isDark,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
    required this.paper,
    required this.innerPaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: isDark ? 0.06 : 0.11),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lightGold.withValues(alpha: 0.8)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: innerPaper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: lightGold.withValues(alpha: 0.25)),
              ),
              child: Stack(
                children: [
                  ...[
                    Alignment.topRight,
                    Alignment.topLeft,
                    Alignment.bottomRight,
                    Alignment.bottomLeft,
                  ].map(
                    (alignment) => Align(
                      alignment: alignment,
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: gold.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        DuaPickerIcon(
                          icon: isFavoritesSelected
                              ? Icons.favorite_rounded
                              : Icons.category_rounded,
                          gold: gold,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التصنيف',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedCategoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: gold,
                          size: 26,
                        ),
                      ],
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

class DuaPickerIcon extends StatelessWidget {
  final IconData icon;
  final Color gold;

  const DuaPickerIcon({super.key, required this.icon, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: gold, size: 22),
    );
  }
}

class DuaCategoryPickerSheet extends StatelessWidget {
  final List<MapEntry<String, String>> options;
  final String selectedValue;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const DuaCategoryPickerSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
  });

  static Future<String?> show({
    required BuildContext context,
    required List<MapEntry<String, String>> options,
    required String selectedValue,
    required Color paper,
    required Color innerPaper,
    required Color gold,
    required Color lightGold,
    required Color textColor,
    required Color mutedColor,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DuaCategoryPickerSheet(
        options: options,
        selectedValue: selectedValue,
        paper: paper,
        innerPaper: innerPaper,
        gold: gold,
        lightGold: lightGold,
        textColor: textColor,
        mutedColor: mutedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: gold.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: lightGold,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              children: [
                DuaPickerIcon(icon: Icons.category_rounded, gold: gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر التصنيف',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اختر التصنيف الذي تريد عرض أدعيته',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
              ],
            ),
          ),
          Divider(height: 1, color: lightGold.withValues(alpha: 0.35)),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.key == selectedValue;

                return InkWell(
                  onTap: () => Navigator.pop(context, option.key),
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? gold.withValues(alpha: 0.13)
                          : innerPaper,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? gold
                            : lightGold.withValues(alpha: 0.35),
                        width: isSelected ? 1.3 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: gold,
                          size: 21,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.value,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Text(
                            'الحالي',
                            style: TextStyle(
                              color: gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
