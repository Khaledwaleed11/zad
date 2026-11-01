import 'package:flutter/material.dart';

import 'settings_group.dart';

class SettingsAboutDialog {
  static void show({
    required BuildContext context,
    required Color gold,
    required Color innerPaper,
    required Color lightGold,
    required Color textColor,
    required Color mutedColor,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: SettingsGroup(
            gold: gold,
            innerPaper: innerPaper,
            lightGold: lightGold,
            radius: 23,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 30,
                    color: gold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'عن زاد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'زاد هو تطبيق إسلامي يساعدك على متابعة القرآن الكريم والأذكار ومواقيت الصلاة واتجاه القبلة والسبحة في مكان واحد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 17,
                        color: gold,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: innerPaper,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}