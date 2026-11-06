import 'package:flutter/material.dart';

class DuaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DuaAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFA88746).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6BE83)),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 19,
              color: Color(0xFFA88746),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'الأدعية',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
