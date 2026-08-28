import 'package:flutter/material.dart';

import '../models/azkar_model.dart';

class ZikrCard extends StatefulWidget {
  final AzkarModel zekr;

  const ZikrCard({super.key, required this.zekr});

  @override
  State<ZikrCard> createState() => _ZikrCardState();
}

class _ZikrCardState extends State<ZikrCard> {
  late int remainingCount;

  @override
  void initState() {
    super.initState();

    remainingCount = widget.zekr.count;
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
    final colors = Theme.of(context).colorScheme;

    final bool completed = remainingCount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: completed
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),

      child: Material(
        color: Colors.transparent,

        borderRadius: BorderRadius.circular(22),

        child: InkWell(
          onTap: completed ? null : incrementZikr,

          borderRadius: BorderRadius.circular(22),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.10),

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        completed
                            ? Icons.check_rounded
                            : Icons.auto_awesome_rounded,

                        color: colors.primary,

                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        widget.zekr.title,

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: resetZikr,

                      tooltip: 'إعادة',

                      visualDensity: VisualDensity.compact,

                      icon: Icon(
                        Icons.refresh_rounded,

                        size: 19,

                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Directionality(
                  textDirection: TextDirection.rtl,

                  child: Text(
                    widget.zekr.text,

                    textAlign: TextAlign.right,

                    style: TextStyle(
                      fontSize: 20,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: completed
                        ? colors.primary.withValues(alpha: 0.10)
                        : colors.surfaceContainerLow,

                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_rounded,

                        size: 18,

                        color: colors.primary,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        completed ? 'تم الذكر' : 'اضغط للتكرار',

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        completed ? '✓' : '$remainingCount',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
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
    );
  }
}
