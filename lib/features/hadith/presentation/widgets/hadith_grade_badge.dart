
import 'package:flutter/material.dart';

class HadithGradeBadge extends StatelessWidget {
  final String grade;

  const HadithGradeBadge({
    super.key,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSahih = grade == 'صحيح';

    final color = isDark
        ? (isSahih ? const Color(0xFFD6BE83) : const Color(0xFFC99B62))
        : (isSahih ? const Color(0xFFA88746) : const Color(0xFFB47A3C));

    final backgroundColor = color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSahih ? Icons.verified_rounded : Icons.info_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            grade.isEmpty ? 'غير محدد' : grade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
