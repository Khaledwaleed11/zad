import 'package:flutter/material.dart';

class QiblaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final VoidCallback onRefresh;

  const QiblaAppBar({
    super.key,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightGold),
            ),
            child: Icon(Icons.explore_rounded, color: gold, size: 21),
          ),
          const SizedBox(width: 10),
          Text(
            'اتجاه القبلة',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onRefresh,
          tooltip: 'تحديث',
          icon: Icon(Icons.refresh_rounded, color: gold),
        ),
      ],
    );
  }
}
