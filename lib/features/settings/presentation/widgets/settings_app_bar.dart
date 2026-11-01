import 'package:flutter/material.dart';

class SettingsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Color paper;
  final Color gold;
  final Color textColor;

  const SettingsAppBar({
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
          _buildIconBox(),
          const SizedBox(width: 10),
          Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: gold.withValues(alpha: 0.4),
        ),
      ),
      child: Icon(
        Icons.settings_rounded,
        size: 38 * 0.52,
        color: gold,
      ),
    );
  }
}