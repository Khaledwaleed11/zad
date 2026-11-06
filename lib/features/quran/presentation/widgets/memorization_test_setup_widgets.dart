import 'package:flutter/material.dart';

class MemorizationTestSetupHeader extends StatelessWidget {
  final Color surface;
  final Color gold;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;

  const MemorizationTestSetupHeader({
    super.key,
    required this.surface,
    required this.gold,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_rounded, color: gold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختبر حفظك للقرآن',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'اختر النطاق والمستوى المناسب لك وابدأ رحلتك',
                  style: TextStyle(color: mutedColor, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemorizationTestSetupSectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const MemorizationTestSetupSectionTitle({
    super.key,
    required this.title,
    required this.textColor,
  });

  static const Color _gold = Color(0xFFA88746);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 21,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class MemorizationTestSetupSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color surface;
  final Color borderColor;
  final Color textColor;

  const MemorizationTestSetupSectionCard({
    super.key,
    required this.title,
    required this.child,
    required this.surface,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class MemorizationTestSetupSelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final Color surface;
  final Color gold;
  final Color borderColor;

  const MemorizationTestSetupSelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.surface,
    required this.gold,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? gold.withValues(alpha: 0.09) : surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isSelected ? gold : borderColor,
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MemorizationTestSetupIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const MemorizationTestSetupIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  static const Color _gold = Color(0xFFA88746);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: isSelected ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: _gold, size: 23),
    );
  }
}
