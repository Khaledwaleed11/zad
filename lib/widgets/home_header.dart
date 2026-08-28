import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const HomeHeader({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السلام عليكم 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'مرحبًا بك في زاد',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'اجعل يومك عامرًا بذكر الله',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15),

          child: InkWell(
            onTap: onSettingsTap,
            borderRadius: BorderRadius.circular(15),

            child: Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),

                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),

              child: Icon(
                Icons.settings_outlined,
                color: colors.onSurface,
                size: 23,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
