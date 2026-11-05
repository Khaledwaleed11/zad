import 'package:flutter/material.dart';

import '../../domain/entities/surah_entity.dart';

class SurahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SurahEntity surah;
  final VoidCallback onRefresh;

  const SurahAppBar({super.key, required this.surah, required this.onRefresh});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            surah.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            surah.englishName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onRefresh,
          tooltip: 'تحديث',
          icon: Icon(Icons.refresh_rounded, color: colors.primary),
        ),
      ],
    );
  }
}
