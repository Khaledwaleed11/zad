import 'package:flutter/material.dart';

class QuranEmptyView extends StatelessWidget {
  final VoidCallback onClear;

  const QuranEmptyView({super.key, required this.onClear});

  Widget _buildIconContainer(
    ColorScheme colors,
    IconData icon, {
    double size = 42,
    double iconSize = 21,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: colors.primary, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(
              colors,
              Icons.search_off_rounded,
              size: 78,
              iconSize: 35,
            ),
            const SizedBox(height: 18),
            Text(
              'لم نجد سورة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب اسم السورة أو رقمها.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: const Text('مسح البحث'),
            ),
          ],
        ),
      ),
    );
  }
}
