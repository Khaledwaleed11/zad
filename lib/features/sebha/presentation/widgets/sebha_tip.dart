import 'package:flutter/material.dart';

class SebhaTip extends StatelessWidget {
  final Color gold;
  final Color mutedColor;

  const SebhaTip({
    super.key,
    required this.gold,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 20,
            color: gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم حفظ تقدمك تلقائيًا حتى بعد إغلاق التطبيق.',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: gold.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}