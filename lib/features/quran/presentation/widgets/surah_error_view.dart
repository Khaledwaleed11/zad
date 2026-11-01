
import 'package:flutter/material.dart';

class SurahErrorView extends StatelessWidget {
  final ColorScheme colors;
  final VoidCallback onRetry;

  const SurahErrorView({
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
            _buildStatusIcon(
              Icons.cloud_off_rounded,
              isError: true,
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل السورة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
      IconData icon, {
        bool isError = false,
      }) {
    final iconColor = isError ? colors.error : colors.primary;

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(icon, size: 35, color: iconColor),
    );
  }
}
