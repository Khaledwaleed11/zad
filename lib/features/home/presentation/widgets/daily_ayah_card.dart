import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../quran/domain/entities/quran_ayah_entity.dart';
import '../../../quran/presentation/cubit/quran_cubit.dart';
import '../../../quran/presentation/cubit/quran_state.dart';

class DailyAyahCard extends StatefulWidget {
  const DailyAyahCard({super.key});

  @override
  State<DailyAyahCard> createState() => _DailyAyahCardState();
}

class _DailyAyahCardState extends State<DailyAyahCard> {
  late final QuranCubit quranCubit;

  @override
  void initState() {
    super.initState();
    quranCubit = sl<QuranCubit>();
    loadAyah();
  }

  Future<void> loadAyah() async {
    await quranCubit.loadRandomAyah();
  }

  @override
  void dispose() {
    quranCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.07 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: lightGold.withValues(alpha: 0.8),
            width: 0.9,
          ),
        ),
        child: BlocBuilder<QuranCubit, QuranState>(
          bloc: quranCubit,
          builder: (context, state) {
            return _buildContent(state, isDark, gold, lightGold);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    QuranState state,
    bool isDark,
    Color gold,
    Color lightGold,
  ) {
    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    if (state.randomAyahStatus == QuranRequestStatus.loading ||
        state.randomAyahStatus == QuranRequestStatus.initial) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: gold),
              ),
              const SizedBox(height: 14),
              Text(
                'جاري تحميل الآية...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.randomAyahStatus == QuranRequestStatus.failure ||
        state.randomAyah == null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 38, color: gold),
              const SizedBox(height: 12),
              Text(
                'تعذر تحميل الآية',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: loadAyah,
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: BorderSide(color: lightGold),
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

    final QuranAyahEntity ayah = state.randomAyah!;

    return Stack(
      children: [
        Positioned(
          top: 7,
          right: 8,
          child: Icon(
            Icons.auto_awesome,
            size: 18,
            color: gold.withValues(alpha: 0.65),
          ),
        ),
        Positioned(
          top: 7,
          left: 8,
          child: Icon(
            Icons.auto_awesome,
            size: 18,
            color: gold.withValues(alpha: 0.65),
          ),
        ),
        Positioned(
          bottom: 7,
          right: 8,
          child: Icon(
            Icons.auto_awesome,
            size: 18,
            color: gold.withValues(alpha: 0.65),
          ),
        ),
        Positioned(
          bottom: 7,
          left: 8,
          child: Icon(
            Icons.auto_awesome,
            size: 18,
            color: gold.withValues(alpha: 0.65),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 20, 17, 16),
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
                      '۞  آية اليوم  ۞',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: gold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: loadAyah,
                    tooltip: 'آية جديدة',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.refresh_rounded, color: gold, size: 21),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Divider(color: lightGold, height: 1),
              const SizedBox(height: 17),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  '﴿ ${ayah.text} ﴾',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    height: 2,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  '${ayah.surahName} • الآية ${ayah.numberInSurah}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 19),
              Divider(color: lightGold, height: 1),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 16, color: gold),
                  const SizedBox(width: 7),
                  Text(
                    'من القرآن الكريم',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: mutedColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'آية جديدة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: gold),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
