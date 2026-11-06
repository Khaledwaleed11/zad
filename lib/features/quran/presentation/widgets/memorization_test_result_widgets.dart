import 'package:flutter/material.dart';

class MemorizationAnswerSlot extends StatelessWidget {
  final String word;
  final bool isSubmitted;
  final bool isCorrect;
  final Color gold;

  const MemorizationAnswerSlot({
    super.key,
    required this.word,
    required this.isSubmitted,
    required this.isCorrect,
    required this.gold,
  });

  static const Color _green = Color(0xFF4C9365);
  static const Color _red = Color(0xFFB65C4E);

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? _green : _red;
    final backgroundColor = !isSubmitted
        ? gold.withValues(alpha: 0.08)
        : statusColor.withValues(alpha: 0.12);
    final borderColor = !isSubmitted
        ? gold.withValues(alpha: 0.65)
        : statusColor.withValues(alpha: 0.7);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 65,
        maxWidth: 150,
        minHeight: 39,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Text(
        word.isEmpty ? '...' : word,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: isSubmitted ? statusColor : gold,
          fontSize: 19,
          height: 1.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MemorizationResultStat extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final Color paperColor;
  final Color goldColor;
  final Color borderColor;
  final Color mutedColor;
  final bool isDark;

  const MemorizationResultStat({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.paperColor,
    required this.goldColor,
    required this.borderColor,
    required this.mutedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: goldColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: isDark ? 0.05 : 0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemorizationMissedAyah extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final Color paperColor;
  final Color innerPaperColor;
  final Color borderColor;
  final Color goldColor;
  final Color textColor;
  final Color mutedColor;

  const MemorizationMissedAyah({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.paperColor,
    required this.innerPaperColor,
    required this.borderColor,
    required this.goldColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: innerPaperColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(Icons.bookmark_outline_rounded, color: goldColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                surahName.isNotEmpty ? surahName : 'سورة رقم $surahNumber',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              'الآية $ayahNumber',
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
