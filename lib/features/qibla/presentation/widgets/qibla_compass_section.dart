import 'package:flutter/material.dart';

import 'qibla_compass.dart';
import 'qibla_paper_card.dart';

class QiblaCompassSection extends StatelessWidget {
  final bool hasCompass;
  final bool isAligned;
  final Animation<double> pulseController;
  final double rotation;

  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color mutedColor;

  const QiblaCompassSection({
    super.key,
    required this.hasCompass,
    required this.isAligned,
    required this.pulseController,
    required this.rotation,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return QiblaPaperCard(
      isDark: isDark,
      paper: paper,
      innerPaper: innerPaper,
      gold: gold,
      lightGold: lightGold,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hasCompass ? gold : mutedColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                !hasCompass
                    ? 'جاري معايرة البوصلة...'
                    : isAligned
                    ? 'أنت الآن على القبلة'
                    : 'ابحث عن اتجاه القبلة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: hasCompass && isAligned ? gold : mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final pulse = isAligned
                  ? 1 + (pulseController.value * 0.015)
                  : 1.0;

              return Transform.scale(scale: pulse, child: child);
            },
            child: QiblaCompass(rotation: rotation),
          ),

          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              !hasCompass
                  ? 'حرّك الهاتف وانتظر قراءة البوصلة'
                  : isAligned
                  ? 'ممتاز، اتجاهك صحيح ✓'
                  : 'أدر الهاتف يمينًا أو يسارًا',
              key: ValueKey('${hasCompass}_$isAligned'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: hasCompass && isAligned ? gold : mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
