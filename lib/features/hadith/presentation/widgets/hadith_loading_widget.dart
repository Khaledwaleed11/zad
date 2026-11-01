
import 'package:flutter/material.dart';

class HadithLoadingWidget extends StatelessWidget {
  final String message;

  const HadithLoadingWidget({
    super.key,
    this.message = 'جاري تحميل الحديث...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goldColor = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: goldColor,
              backgroundColor: goldColor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
