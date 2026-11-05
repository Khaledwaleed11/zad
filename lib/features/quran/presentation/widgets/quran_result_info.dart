import 'package:flutter/material.dart';

class QuranResultInfo extends StatelessWidget {
  final int resultCount;
  final bool isSearching;
  final VoidCallback onClear;

  const QuranResultInfo({
    super.key,
    required this.resultCount,
    required this.isSearching,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 13,
          color: colors.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          isSearching ? '$resultCount نتيجة' : '$resultCount سورة',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (isSearching)
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'مسح البحث',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
