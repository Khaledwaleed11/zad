import 'package:flutter/material.dart';

import '../../domain/entities/azkar_entity.dart';
import 'zikr_card.dart';

class AzkarList extends StatelessWidget {
  final List<AzkarEntity> azkar;
  final String selectedCategory;
  final ValueChanged<AzkarEntity> onEdit;
  final ValueChanged<AzkarEntity> onDelete;

  const AzkarList({
    super.key,
    required this.azkar,
    required this.selectedCategory,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final zekr = azkar[index];

        final double startDelay = (index * 0.035).clamp(0.0, 0.45);

        return TweenAnimationBuilder<double>(
          key: ValueKey('${selectedCategory}_${zekr.id}'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final adjustedValue = ((value - startDelay) / (1 - startDelay))
                .clamp(0.0, 1.0);

            return Opacity(
              opacity: adjustedValue,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - adjustedValue)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ZikrCard(
              key: ValueKey(zekr.id),
              zekr: zekr,
              onEdit: () => onEdit(zekr),
              onDelete: () => onDelete(zekr),
            ),
          ),
        );
      }, childCount: azkar.length),
    );
  }
}
