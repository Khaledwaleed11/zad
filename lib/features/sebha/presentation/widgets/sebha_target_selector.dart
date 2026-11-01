import 'dart:math' as math;

import 'package:flutter/material.dart';

class SebhaTargetSelector extends StatelessWidget {
  final int target;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<int> onChanged;

  const SebhaTargetSelector({
    super.key,
    required this.target,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: gold.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: _cornerDecoration(),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi,
                child: _cornerDecoration(),
              ),
            ),
            Row(
              children: [
                _buildIconBox(),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هدف التسبيح',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$target مرة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 33,
                      label: Text('33'),
                    ),
                    ButtonSegment<int>(
                      value: 99,
                      label: Text('99'),
                    ),
                  ],
                  selected: {target},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      onChanged(selection.first);
                    }
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor:
                    WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? innerPaper
                          : gold;
                    }),
                    backgroundColor:
                    WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? gold
                          : paper;
                    }),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: gold.withValues(alpha: 0.55),
                      ),
                    ),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        Icons.flag_rounded,
        color: gold,
        size: 40 * 0.52,
      ),
    );
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: gold.withValues(alpha: 0.65),
    );
  }
}