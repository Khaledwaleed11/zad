import 'package:flutter/material.dart';

import '../models/surah_model.dart';

class SurahItem extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const SurahItem({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bool isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Material(
        color: Colors.transparent,

        borderRadius: BorderRadius.circular(18),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(18),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.englishName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${surah.numberOfAyahs} آية',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isMeccan
                            ? colors.primary.withValues(alpha: 0.10)
                            : colors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isMeccan ? 'مكية' : 'مدنية',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
