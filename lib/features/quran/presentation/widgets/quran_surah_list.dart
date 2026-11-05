import 'package:flutter/material.dart';

import '../../domain/entities/surah_entity.dart';
import 'quran_surah_card.dart';

class QuranSurahList extends StatelessWidget {
  final List<SurahEntity> surahs;
  final String searchQuery;
  final ValueChanged<SurahEntity> onSurahTap;

  const QuranSurahList({
    super.key,
    required this.surahs,
    required this.searchQuery,
    required this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final surah = surahs[index];
          final delay = (index * 0.035).clamp(0.0, 0.55);

          return TweenAnimationBuilder<double>(
            key: ValueKey('${surah.number}_$searchQuery'),
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final adjusted = (value - delay).clamp(0.0, 1.0);

              return Opacity(
                opacity: adjusted,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - adjusted)),
                  child: child,
                ),
              );
            },
            child: QuranSurahCard(surah: surah, onTap: () => onSurahTap(surah)),
          );
        }, childCount: surahs.length),
      ),
    );
  }
}
