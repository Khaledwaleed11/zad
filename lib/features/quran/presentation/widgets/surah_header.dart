
import 'package:flutter/material.dart';

import '../../domain/entities/surah_entity.dart';
import '../cubit/quran_state.dart';

class SurahHeader extends StatelessWidget {
  final SurahEntity surah;
  final QuranAudioStatus audioStatus;
  final VoidCallback onPlay;
  final bool isLoading;
  final bool isPlaying;

  const SurahHeader({
    super.key,
    required this.surah,
    required this.audioStatus,
    required this.onPlay,
    required this.isLoading,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bool isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.75),
          width: 1.2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            _buildDecoration(colors),
            const SizedBox(height: 14),
            Text(
              surah.name,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surah.englishName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _SurahInfoChip(
                  icon: Icons.auto_stories_rounded,
                  text: '${surah.numberOfAyahs} آية',
                ),
                _SurahInfoChip(
                  icon: Icons.location_on_outlined,
                  text: isMeccan ? 'مكية' : 'مدنية',
                ),
                _SurahInfoChip(
                  icon: Icons.numbers_rounded,
                  text: '#${surah.number}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onPlay,
                icon: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 22,
                ),
                label: Text(
                  isLoading
                      ? 'جاري التحميل...'
                      : isPlaying
                      ? 'إيقاف مؤقت'
                      : audioStatus == QuranAudioStatus.paused
                      ? 'استكمال التلاوة'
                      : 'استمع للسورة كاملة',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.primary.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: colors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildDecoration(
              colors,
              icon: Icons.diamond_outlined,
              iconSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecoration(
      ColorScheme colors, {
        IconData icon = Icons.auto_awesome,
        double iconSize = 17,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _decorationLine(colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Icon(icon, color: colors.primary, size: iconSize),
        ),
        _decorationLine(colors),
      ],
    );
  }

  Widget _decorationLine(ColorScheme colors) {
    return Container(
      width: 38,
      height: 1,
      color: colors.primary.withValues(alpha: 0.55),
    );
  }
}

class _SurahInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SurahInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
