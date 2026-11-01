import 'package:flutter/material.dart';

class QiblaStatusCard extends StatelessWidget {
  final double rotation;
  final bool hasCompass;
  final bool isAligned;

  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;

  const QiblaStatusCard({
    super.key,
    required this.rotation,
    required this.hasCompass,
    required this.isAligned,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAligned ? gold : lightGold,
          width: isAligned ? 1.5 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: lightGold.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: lightGold),
              ),
              child: Icon(
                isAligned
                    ? Icons.check_rounded
                    : rotation < 30
                    ? Icons.navigation_rounded
                    : Icons.screen_rotation_alt_rounded,
                size: 21,
                color: gold,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  !hasCompass
                      ? 'في انتظار قراءة البوصلة'
                      : isAligned
                      ? 'اتجاه القبلة مضبوط'
                      : 'تبقى ${rotation.toStringAsFixed(0)}° للوصول إلى القبلة',
                  key: ValueKey(
                    !hasCompass
                        ? 'waiting'
                        : isAligned
                        ? 'aligned'
                        : rotation.toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hasCompass ? '${rotation.toStringAsFixed(0)}°' : '--°',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
