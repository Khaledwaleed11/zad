import 'dart:math' as math;

import 'package:flutter/material.dart';

class SebhaZikrSelector extends StatelessWidget {
  final List<String> availableAzkar;
  final String selectedZikr;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<String> onChanged;

  const SebhaZikrSelector({
    super.key,
    required this.availableAzkar,
    required this.selectedZikr,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
    required this.onChanged,
  });

  Future<void> _showZikrPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: gold.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: lightGold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Row(
                  children: [
                    _buildIconBox(Icons.menu_book_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر الذكر',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر الذكر الذي تريد التسبيح به',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: gold,
                      size: 22,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: lightGold.withValues(alpha: 0.35),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  itemCount: availableAzkar.length,
                  separatorBuilder: (_, _) =>
                  const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final zikr = availableAzkar[index];
                    final isSelected = zikr == selectedZikr;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext, zikr);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? gold.withValues(alpha: 0.13)
                              : innerPaper,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? gold
                                : lightGold.withValues(alpha: 0.35),
                            width: isSelected ? 1.3 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: gold,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                zikr,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Text(
                                'الحالي',
                                style: TextStyle(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result != selectedZikr) {
      onChanged(result);
    }
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        icon,
        color: gold,
        size: 42 * 0.52,
      ),
    );
  }

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
        padding: const EdgeInsets.all(16),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 17,
                      color: gold,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'اختر الذكر',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                InkWell(
                  onTap: () => _showZikrPicker(context),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: lightGold.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: gold,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedZikr,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: gold,
                          size: 25,
                        ),
                      ],
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

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: gold.withValues(alpha: 0.65),
    );
  }
}
