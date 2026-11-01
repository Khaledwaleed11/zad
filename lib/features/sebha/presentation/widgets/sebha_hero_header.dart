import 'package:flutter/material.dart';

class SebhaHeroHeader extends StatelessWidget {
  final Animation<double> ambientAnimation;
  final Color gold;
  final Color innerPaper;
  final Color lightGold;
  final Color mutedColor;
  final Color textColor;

  const SebhaHeroHeader({
    super.key,
    required this.ambientAnimation,
    required this.gold,
    required this.innerPaper,
    required this.lightGold,
    required this.mutedColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambientAnimation,
      builder: (context, child) {
        final glow = 0.07 + (ambientAnimation.value * 0.04);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: gold.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: glow),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: innerPaper,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: lightGold.withValues(alpha: 0.55),
              ),
            ),
            child: child,
          ),
        );
      },
      child: Row(
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
              Icons.fingerprint_rounded,
              color: gold,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اذكر الله يطمئن قلبك',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'سبّح واطمئن',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ذكر بسيط • أثر كبير',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
    );
  }
}