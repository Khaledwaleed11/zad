
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const HomeHeader({
    super.key,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final gold =
    isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

    final textColor =
    isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

    final mutedColor =
    isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

    final paper =
    isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السلام عليكم 👋',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'مرحبًا بك في زاد',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: gold,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'اجعل يومك عامرًا بذكر الله',
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 49,
            height: 49,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: gold,
                width: 1.2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gold.withValues(alpha: 0.45),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onSettingsTap,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: gold.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.settings_outlined,
                    color: gold,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
