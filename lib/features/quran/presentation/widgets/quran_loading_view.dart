import 'package:flutter/material.dart';

class QuranLoadingView extends StatelessWidget {
  const QuranLoadingView({super.key});

  Widget _shimmerBox(
      BuildContext context, {
        required double width,
        required double height,
        required double radius,
      }) {
    final colors = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.75),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      child: Column(
        children: List.generate(
          6,
              (index) => Container(
            height: 78,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _shimmerBox(
                    context,
                    width: 44,
                    height: 44,
                    radius: 13,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(
                          context,
                          width: 90,
                          height: 14,
                          radius: 5,
                        ),
                        const SizedBox(height: 8),
                        _shimmerBox(
                          context,
                          width: 130,
                          height: 9,
                          radius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}