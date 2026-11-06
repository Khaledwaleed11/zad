import 'package:flutter/material.dart';

class ProphetStoriesLoadingView extends StatelessWidget {
  final String message;

  const ProphetStoriesLoadingView({
    super.key,
    this.message = 'جاري تحميل قصص الأنبياء...',
  });

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: gold,
              backgroundColor: gold.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProphetStoriesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProphetStoriesErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gold = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: colors.error,
                size: 35,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              'تعذر تحميل قصص الأنبياء',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProphetStoriesEmptyView extends StatelessWidget {
  const ProphetStoriesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: gold, size: 46),
            const SizedBox(height: 14),
            Text(
              'لا توجد قصص مطابقة للبحث',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
