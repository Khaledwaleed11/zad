import 'package:flutter/material.dart';

import 'qibla_paper_card.dart';

class QiblaLoadingView extends StatelessWidget {
  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const QiblaLoadingView({
    super.key,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: QiblaPaperCard(
          isDark: isDark,
          paper: paper,
          innerPaper: innerPaper,
          gold: gold,
          lightGold: lightGold,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: lightGold),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(19),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: gold,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'جاري تحديد اتجاه القبلة...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اسمح للتطبيق بالوصول إلى موقعك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QiblaErrorView extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  final bool isDark;
  final Color paper;
  final Color innerPaper;
  final Color gold;
  final Color lightGold;
  final Color textColor;
  final Color mutedColor;

  const QiblaErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.isDark,
    required this.paper,
    required this.innerPaper,
    required this.gold,
    required this.lightGold,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final compassError = error != null && error!.contains('البوصلة');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: QiblaPaperCard(
          isDark: isDark,
          paper: paper,
          innerPaper: innerPaper,
          gold: gold,
          lightGold: lightGold,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: lightGold),
                ),
                child: Icon(
                  compassError
                      ? Icons.explore_off_rounded
                      : Icons.location_off_rounded,
                  size: 38,
                  color: gold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                compassError ? 'البوصلة غير متاحة' : 'تعذر تحديد القبلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                compassError
                    ? 'جهازك لا يوفر حساس بوصلة صالحًا للاستخدام.'
                    : 'تأكد من تشغيل الموقع ومنح التطبيق صلاحية الوصول إليه.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: gold,
                  ),
                  label: Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gold),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
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