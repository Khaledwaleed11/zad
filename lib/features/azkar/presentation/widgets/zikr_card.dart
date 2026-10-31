import 'package:flutter/material.dart';

import '../../domain/entities/azkar_entity.dart';

class ZikrCard extends StatefulWidget {
  final AzkarEntity zekr;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ZikrCard({
    super.key,
    required this.zekr,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ZikrCard> createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard> {
  late int remainingCount;

  static const _paper = Color(0xFFF7F1DF);
  static const _innerPaper = Color(0xFFFFFCF4);
  static const _darkPaper = Color(0xFF252017);
  static const _darkInnerPaper = Color(0xFF201B13);
  static const _brown = Color(0xFF493A25);
  static const _gold = Color(0xFFA88746);
  static const _lightGold = Color(0xFFD6BE83);

  @override
  void initState() {
    super.initState();
    remainingCount = widget.zekr.count;
  }

  @override
  void didUpdateWidget(covariant ZikrCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.zekr.id != widget.zekr.id ||
        oldWidget.zekr.count != widget.zekr.count) {
      remainingCount = widget.zekr.count;
    }
  }

  void incrementZikr() {
    if (remainingCount <= 0) return;

    setState(() {
      remainingCount--;
    });
  }

  void resetZikr() {
    setState(() {
      remainingCount = widget.zekr.count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    final completed = remainingCount == 0;

    final paper = isDark ? _darkPaper : _paper;
    final innerPaper = isDark ? _darkInnerPaper : _innerPaper;
    final gold = isDark ? _lightGold : _gold;
    final lightGold = isDark
        ? const Color(0xFF806B43)
        : _lightGold;
    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : _brown;
    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.06 : 0.11),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.8),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: lightGold.withValues(alpha: 0.25),
            ),
          ),
          child: Stack(
            children: [
              ...[
                 Alignment.topRight,
                 Alignment.topLeft,
                 Alignment.bottomRight,
                 Alignment.bottomLeft,
              ].map(
                    (alignment) =>
                    Align(
                      alignment: alignment,
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: gold.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
              ),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: completed ? null : incrementZikr,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      14, 18, 14, 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: gold.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: lightGold),
                              ),
                              child: Text(
                                completed
                                    ? '۞  تم الذكر  ۞'
                                    : '۞  ${widget.zekr.title}  ۞',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: gold,
                                ),
                              ),
                            ),
                            const Spacer(),

                            if (widget.zekr.isCustom) ...[
                              _ActionIcon(
                                icon: Icons.edit_outlined,
                                color: gold,
                                tooltip: 'تعديل',
                                onTap: widget.onEdit,
                              ),
                              const SizedBox(width: 4),
                              _ActionIcon(
                                icon: Icons.delete_outline_rounded,
                                color: isDark
                                    ? const Color(0xFFE49A8E)
                                    : const Color(0xFFB65C4E),
                                tooltip: 'حذف',
                                onTap: widget.onDelete,
                              ),
                              const SizedBox(width: 4),
                            ],

                            _ActionIcon(
                              icon: Icons.refresh_rounded,
                              color: mutedColor,
                              tooltip: 'إعادة',
                              onTap: resetZikr,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        Divider(color: lightGold, height: 1),
                        const SizedBox(height: 18),

                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            widget.zekr.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              height: 1.9,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: lightGold.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: gold,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: lightGold.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withValues(
                              alpha: completed ? 0.14 : 0.07,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: lightGold.withValues(alpha: 0.65),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                completed
                                    ? Icons.check_circle_rounded
                                    : Icons.touch_app_rounded,
                                size: 18,
                                color: gold,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  completed
                                      ? 'تم الذكر، تقبل الله منك'
                                      : 'اضغط للتكرار',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                              Text(
                                completed ? '✓' : '$remainingCount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18, color: color),
    );
  }
}
