
import 'package:flutter/material.dart';

import '../../domain/entities/quran_ayah_entity.dart';
import '../cubit/quran_state.dart';

class AyahCard extends StatelessWidget {
  final QuranAyahEntity ayah;
  final bool isCurrentAyah;
  final QuranAudioStatus audioStatus;
  final VoidCallback onPlayAudio;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.isCurrentAyah,
    required this.audioStatus,
    required this.onPlayAudio,
    required this.onCopy,
    required this.onShare,
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

    final isPlaying =
        isCurrentAyah && audioStatus == QuranAudioStatus.playing;
    final isLoading =
        isCurrentAyah && audioStatus == QuranAudioStatus.loading;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: isCurrentAyah ? 1.8 : 1.3),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.07 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.8),
            width: 0.9,
          ),
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
                    size: 18,
                    color: gold.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: lightGold),
                        ),
                        child: Text(
                          '۞  ${ayah.numberInSurah}  ۞',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _SmallActionButton(
                        icon: isLoading
                            ? Icons.hourglass_top_rounded
                            : isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: onPlayAudio,
                        isActive: isCurrentAyah,
                      ),
                      const SizedBox(width: 5),
                      _SmallActionButton(
                        icon: Icons.copy_rounded,
                        onTap: onCopy,
                      ),
                      const SizedBox(width: 5),
                      _SmallActionButton(
                        icon: Icons.share_outlined,
                        onTap: onShare,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Divider(color: lightGold, height: 1),
                  const SizedBox(height: 17),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '﴿ ${ayah.text} ﴾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        height: 2,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '${ayah.surahName} • الآية ${ayah.numberInSurah}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 19),
                  Divider(color: lightGold, height: 1),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 16, color: gold),
                      const SizedBox(width: 7),
                      Text(
                        'من القرآن الكريم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: mutedColor,
                        ),
                      ),
                      const Spacer(),
                      if (isCurrentAyah) ...[
                        Icon(
                          isPlaying
                              ? Icons.volume_up_rounded
                              : Icons.graphic_eq_rounded,
                          size: 15,
                          color: gold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPlaying ? 'تُتلى الآن' : 'متوقفة مؤقتًا',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: gold,
                          ),
                        ),
                      ],
                    ],
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

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _SmallActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colors.primary.withValues(alpha: 0.14)
          : colors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, size: 16, color: colors.primary),
        ),
      ),
    );
  }
}
