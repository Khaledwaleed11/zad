import 'package:flutter/material.dart';

class DuaEmptyView extends StatelessWidget {
  final bool showFavoritesOnly;
  final Color mutedColor;

  const DuaEmptyView({
    super.key,
    required this.showFavoritesOnly,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          showFavoritesOnly ? 'لا توجد أدعية في المفضلة' : 'لا توجد أدعية',
          style: TextStyle(color: mutedColor, fontSize: 15),
        ),
      ),
    );
  }
}
