import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/written_dua_entity.dart';
import 'dua_filters.dart';

class DuaDetailsSheet {
  const DuaDetailsSheet._();

  static void show({
    required BuildContext context,
    required WrittenDuaEntity dua,
    required Color gold,
    required Color textColor,
    required Color mutedColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);
    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFEDE2C7);
    const lightGold = Color(0xFFD6BE83);

    showModalBottomSheet(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: gold.withValues(alpha: 0.6)),
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
                    DuaPickerIcon(icon: Icons.menu_book_rounded, gold: gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نص الدعاء',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اقرأ الدعاء وانسخه بسهولة',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
                  ],
                ),
              ),
              Divider(height: 1, color: lightGold.withValues(alpha: 0.35)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: gold.withValues(alpha: 0.75)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: innerPaper,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lightGold.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        dua.arabicText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          height: 2.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dua.arabicText));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الدعاء')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('نسخ الدعاء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
