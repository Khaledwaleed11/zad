import 'package:flutter/material.dart';

class QiblaPaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;

  const QiblaPaperCard({
    super.key,
    required this.child,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    this.padding = const EdgeInsets.all(5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.05 : 0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGold, width: 0.8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGold.withValues(alpha: 0.25)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 5,
                child: _buildCornerDecoration('top_right'),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: _buildCornerDecoration('top_left'),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: _buildCornerDecoration('bottom_right'),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: _buildCornerDecoration('bottom_left'),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerDecoration(String key) {
    return Icon(
      Icons.auto_awesome,
      key: ValueKey(key),
      size: 15,
      color: gold.withValues(alpha: 0.50),
    );
  }
}
