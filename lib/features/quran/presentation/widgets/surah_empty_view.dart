import 'package:flutter/material.dart';

class SurahEmptyView extends StatelessWidget {
  final ColorScheme colors;

  const SurahEmptyView({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIcon(Icons.menu_book_rounded),
            const SizedBox(height: 16),
            Text(
              'لا توجد آيات للعرض',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: 35, color: colors.primary),
    );
  }
}
