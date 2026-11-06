import 'package:flutter/material.dart';

import 'quick_action_card.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onQuranTap;
  final VoidCallback onAzkarTap;
  final VoidCallback onQiblaTap;
  final VoidCallback onSebhaTap;
  final VoidCallback onDuaTap;
  final VoidCallback onProphetsStoriesTap;

  const HomeQuickActions({
    super.key,
    required this.onQuranTap,
    required this.onAzkarTap,
    required this.onQiblaTap,
    required this.onSebhaTap,
    required this.onDuaTap,
    required this.onProphetsStoriesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            QuickActionCard(
              icon: Icons.menu_book_rounded,
              title: 'القرآن',
              subtitle: 'اقرأ وتدبر كتاب الله',
              onTap: onQuranTap,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              icon: Icons.auto_awesome_rounded,
              title: 'الأذكار',
              subtitle: 'أذكارك اليومية',
              onTap: onAzkarTap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
              icon: Icons.explore_rounded,
              title: 'القبلة',
              subtitle: 'حدد اتجاه القبلة',
              onTap: onQiblaTap,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              icon: Icons.touch_app_rounded,
              title: 'السبحة',
              subtitle: 'اذكر الله وسبّح',
              onTap: onSebhaTap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
              icon: Icons.volunteer_activism_rounded,
              title: 'الأدعية',
              subtitle: 'أدعية متنوعة لكل وقت',
              onTap: onDuaTap,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              icon: Icons.auto_stories_rounded,
              title: 'قصص الأنبياء',
              subtitle: 'اقرأ قصص أنبياء الله',
              onTap: onProphetsStoriesTap,
            ),
          ],
        ),
      ],
    );
  }
}
