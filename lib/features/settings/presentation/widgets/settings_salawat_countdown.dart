import 'package:flutter/material.dart';

class SettingsSalawatCountdown extends StatelessWidget {
  final DateTime? nextTime;
  final Color gold;
  final Color mutedColor;

  const SettingsSalawatCountdown({
    super.key,
    required this.nextTime,
    required this.gold,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (nextTime == null) {
      return const SizedBox.shrink();
    }

    final remaining = nextTime!.difference(DateTime.now());
    final isFinished = remaining.inSeconds <= 0;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    final time = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 19,
            color: gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFinished
                  ? 'حان موعد التذكير'
                  : 'التذكير القادم بعد',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
            ),
          ),
          if (!isFinished)
            Text(
              time,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: gold,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
