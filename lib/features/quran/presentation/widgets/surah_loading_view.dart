
import 'package:flutter/material.dart';

class SurahLoadingView extends StatelessWidget {
  final ColorScheme colors;

  const SurahLoadingView({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: Container(
            height: 175,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoadingBox(width: 38, height: 38),
                const SizedBox(height: 22),
                _buildLoadingBox(width: double.infinity, height: 16),
                const SizedBox(height: 10),
                _buildLoadingBox(width: 250, height: 16),
                const SizedBox(height: 10),
                _buildLoadingBox(width: 180, height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBox({
    required double width,
    required double height,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        );
      },
    );
  }
}
