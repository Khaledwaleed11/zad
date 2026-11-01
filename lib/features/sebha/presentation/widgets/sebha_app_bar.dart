import 'package:flutter/material.dart';

class SebhaAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Color paper;
  final Color gold;
  final Color textColor;

  const SebhaAppBar({
    super.key,
    required this.paper,
    required this.gold,
    required this.textColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: gold.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: gold,
              size: 36 * 0.52,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'السبحة',
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}