import 'package:flutter/material.dart';

import '../models/quran_ayah_model.dart';
import '../services/quran_service.dart';

class DailyAyahCard extends StatefulWidget {
  const DailyAyahCard({super.key});

  @override
  State<DailyAyahCard> createState() => _DailyAyahCardState();
}

class _DailyAyahCardState extends State<DailyAyahCard> {
  final QuranService quranService = QuranService();

  QuranAyahModel? ayah;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAyah();
  }

  Future<void> loadAyah() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await quranService.getRandomAyah();

      if (!mounted) return;

      setState(() {
        ayah = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, Colors.black, 0.20)!,
          ],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 14),

              Text(
                'جاري تحميل الآية...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null || ayah == null) {
      return SizedBox(
        height: 220,

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 38,
                color: Colors.white.withValues(alpha: 0.8),
              ),

              const SizedBox(height: 12),

              const Text(
                'تعذر تحميل الآية',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: loadAyah,

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,

                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                icon: const Icon(Icons.refresh_rounded, size: 18),

                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),

                borderRadius: BorderRadius.circular(11),
              ),

              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'آية اليوم',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            IconButton(
              onPressed: loadAyah,

              tooltip: 'آية جديدة',

              visualDensity: VisualDensity.compact,

              icon: Icon(
                Icons.refresh_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 20,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Directionality(
          textDirection: TextDirection.rtl,

          child: Text(
            '﴿ ${ayah!.text} ﴾',

            textAlign: TextAlign.right,

            style: const TextStyle(
              fontSize: 23,
              height: 1.9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Directionality(
          textDirection: TextDirection.rtl,

          child: Text(
            '${ayah!.surahName} • الآية ${ayah!.numberInSurah}',

            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),

        const SizedBox(height: 22),

        Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),

        const SizedBox(height: 14),

        Row(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 17,
              color: Colors.white.withValues(alpha: 0.82),
            ),

            const SizedBox(width: 7),

            Text(
              'من القرآن الكريم',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),

            const Spacer(),

            Text(
              'آية جديدة',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),

            const SizedBox(width: 5),

            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 11,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ],
        ),
      ],
    );
  }
}
