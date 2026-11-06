import 'package:flutter/material.dart';

class PrayerTimesLoadingView extends StatelessWidget {
  final ColorScheme colors;

  const PrayerTimesLoadingView({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل المواقيت...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'نحدد لك الصلاة القادمة',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class PrayerTimesErrorView extends StatelessWidget {
  final ColorScheme colors;
  final VoidCallback onRetry;

  const PrayerTimesErrorView({
    super.key,
    required this.colors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل المواقيت',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تأكد من الاتصال بالإنترنت وحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
