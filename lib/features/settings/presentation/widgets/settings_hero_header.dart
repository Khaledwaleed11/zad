import 'package:flutter/material.dart';

class SettingsHeroHeader extends StatelessWidget {
  final Color gold;
  final Color mutedColor;
  final Color textColor;

  const SettingsHeroHeader({
    super.key,
    required this.gold,
    required this.mutedColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: gold.withValues(alpha: 0.75),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: _cornerDecoration(),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Transform.rotate(
                angle: 1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -1.5708,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: 3.1416,
                child: _cornerDecoration(),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gold.withValues(alpha: 0.12),
                    border: Border.all(
                      color: gold.withValues(alpha: 0.65),
                      width: 1.3,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: gold,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خصّص تجربتك',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'إعدادات زاد',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'كل شيء بالشكل الذي يناسبك',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 21,
                  color: gold.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: gold.withValues(alpha: 0.65),
    );
  }
}