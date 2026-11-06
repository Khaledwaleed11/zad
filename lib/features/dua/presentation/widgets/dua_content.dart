import 'package:flutter/material.dart';

import '../../domain/entities/written_dua_entity.dart';
import 'dua_app_bar.dart';
import 'dua_empty_view.dart';
import 'dua_filters.dart';
import 'written_dua_card.dart';

class DuaContent extends StatelessWidget {
  final TextEditingController searchController;
  final List<WrittenDuaEntity> duas;
  final List<String> favoriteIds;
  final bool showFavoritesOnly;
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
  final ValueChanged<WrittenDuaEntity> onDuaTap;
  final ValueChanged<WrittenDuaEntity> onFavoriteTap;

  const DuaContent({
    super.key,
    required this.searchController,
    required this.duas,
    required this.favoriteIds,
    required this.showFavoritesOnly,
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
    required this.onDuaTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const DuaAppBar(),
          DuaFilters(
            searchController: searchController,
            isDark: isDark,
            isFavoritesSelected: isFavoritesSelected,
            selectedCategoryName: selectedCategoryName,
            gold: gold,
            lightGold: lightGold,
            textColor: textColor,
            mutedColor: mutedColor,
            paper: paper,
            innerPaper: innerPaper,
            onSearchChanged: onSearchChanged,
            onClearSearch: onClearSearch,
            onCategoryTap: onCategoryTap,
          ),
          const SizedBox(height: 8),
          if (duas.isEmpty)
            DuaEmptyView(
              showFavoritesOnly: showFavoritesOnly,
              mutedColor: mutedColor,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              itemCount: duas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final dua = duas[index];

                return WrittenDuaCard(
                  dua: dua,
                  isFavorite: favoriteIds.contains(dua.id),
                  gold: gold,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  paper: paper,
                  onTap: () => onDuaTap(dua),
                  onFavoriteTap: () => onFavoriteTap(dua),
                );
              },
            ),
        ],
      ),
    );
  }
}
