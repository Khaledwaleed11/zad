import 'package:flutter/material.dart';
import '../../domain/entities/surah_entity.dart';
import 'surah_item.dart';

class QuranSurahCard extends StatelessWidget {
  final SurahEntity surah;
  final VoidCallback onTap;

  const QuranSurahCard({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.45),
          width: 0.9,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.20),
            width: 0.7,
          ),
        ),
        child: SurahItem(surah: surah, onTap: onTap),
      ),
    );
  }
}
