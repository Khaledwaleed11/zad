import 'package:flutter/material.dart';

import '../cubit/quran_state.dart';

class QuranReciterSelector extends StatelessWidget {
  final String reciterName;
  final QuranRequestStatus recitersStatus;
  final VoidCallback onTap;

  const QuranReciterSelector({
    super.key,
    required this.reciterName,
    required this.recitersStatus,
    required this.onTap,
  });

  Widget _buildFramedContainer({
    required ColorScheme colors,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(4),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.65),
          width: 1.1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildIconContainer(
    ColorScheme colors,
    IconData icon, {
    double size = 42,
    double iconSize = 21,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: colors.primary, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _buildFramedContainer(
        colors: colors,
        padding: const EdgeInsets.all(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              _buildIconContainer(
                colors,
                Icons.record_voice_over_rounded,
                size: 40,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القارئ الحالي',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reciterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (recitersStatus == QuranRequestStatus.loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              else if (recitersStatus == QuranRequestStatus.failure)
                Icon(Icons.refresh_rounded, color: colors.error)
              else
                Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
