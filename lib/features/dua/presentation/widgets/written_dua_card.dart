import 'package:flutter/material.dart';

import '../../domain/entities/written_dua_entity.dart';

class WrittenDuaCard extends StatelessWidget {
  final WrittenDuaEntity dua;
  final bool isFavorite;
  final Color gold;
  final Color textColor;
  final Color mutedColor;
  final Color paper;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const WrittenDuaCard({
    super.key,
    required this.dua,
    required this.isFavorite,
    required this.gold,
    required this.textColor,
    required this.mutedColor,
    required this.paper,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);
    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

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
          border: Border.all(color: lightGold.withValues(alpha: 0.8)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGold.withValues(alpha: 0.25)),
          ),
          child: Stack(
            children: [
              ...[
                Alignment.topRight,
                Alignment.topLeft,
                Alignment.bottomRight,
                Alignment.bottomLeft,
              ].map(
                (alignment) => Align(
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
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 38,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
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
                                    '۞  الدعاء  ۞',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: gold,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: onFavoriteTap,
                                  tooltip: isFavorite
                                      ? 'إزالة من المفضلة'
                                      : 'إضافة للمفضلة',
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: isFavorite ? gold : mutedColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Divider(color: lightGold, height: 1),
                        const SizedBox(height: 18),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            dua.arabicText,
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
                            color: gold.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: lightGold.withValues(alpha: 0.65),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: gold,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'اضغط لقراءة الدعاء',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                              if (dua.repetitionCount != null) ...[
                                Text(
                                  'التكرار: ${dua.repetitionCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: mutedColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 13,
                                color: gold,
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
