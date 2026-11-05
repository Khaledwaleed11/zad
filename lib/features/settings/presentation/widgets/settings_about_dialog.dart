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
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SettingsGroup(
              gold: gold,
              innerPaper: innerPaper,
              lightGold: lightGold,
              radius: 23,
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Icon
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: gold.withValues(alpha: 0.5)),
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
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'زاد هو رفيقك اليومي في رحلتك الإيمانية، '
                      'تطبيق إسلامي يجمع لك أهم الأدوات والمحتويات '
                      'التي تساعدك على التقرب إلى الله والمحافظة '
                      'على عباداتك بسهولة وفي مكان واحد.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.8,
                        color: mutedColor,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildSectionTitle(
                      'ماذا يقدم لك زاد؟',
                      Icons.widgets_rounded,
                      gold,
                      textColor,
                    ),

                    const SizedBox(height: 12),

                    _buildFeature(
                      icon: Icons.menu_book_rounded,
                      title: 'القرآن الكريم',
                      description:
                          'تصفح سور القرآن الكريم واستمع إلى تلاوات القراء.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    _buildFeature(
                      icon: Icons.favorite_rounded,
                      title: 'الأذكار',
                      description:
                          'حافظ على أذكارك اليومية واجعل ذكر الله جزءًا من يومك.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    _buildFeature(
                      icon: Icons.auto_stories_rounded,
                      title: 'الأحاديث النبوية',
                      description:
                          'اكتشف الأحاديث النبوية وتعرف على هدي النبي ﷺ.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    _buildFeature(
                      icon: Icons.access_time_rounded,
                      title: 'مواقيت الصلاة',
                      description:
                          'تابع مواقيت الصلاة وكن دائمًا على استعداد لأدائها.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    _buildFeature(
                      icon: Icons.explore_rounded,
                      title: 'اتجاه القبلة',
                      description: 'اعرف اتجاه القبلة بسهولة أينما كنت.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    _buildFeature(
                      icon: Icons.radio_button_checked_rounded,
                      title: 'السبحة الإلكترونية',
                      description: 'ساعد نفسك على الاستمرار في التسبيح والذكر.',
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    ),

                    const SizedBox(height: 18),

                    // Vision
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gold.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: gold,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'رؤيتنا',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'نسعى إلى تقديم تجربة إسلامية بسيطة '
                            'ومريحة ومتاحة للجميع، تساعدك على '
                            'جعل العبادة والذكر جزءًا من حياتك اليومية.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.7,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Developer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.code_rounded,
                              color: gold,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تطوير وبرمجة',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mutedColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'خالد وليد',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'لا تنسونا من صالح دعائكم',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.verified_rounded, color: gold, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Version
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_outlined, size: 17, color: gold),
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

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: innerPaper,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text(
                          'إغلاق',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSectionTitle(
    String title,
    IconData icon,
    Color gold,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }

  static Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color gold,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: gold, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
