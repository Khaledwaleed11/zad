import 'package:flutter/material.dart';
import 'package:zad/screens/surah_screen.dart';

import '../models/surah_model.dart';
import '../services/quran_service.dart';
import '../widgets/surah_item.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  final QuranService quranService = QuranService();

  final TextEditingController searchController = TextEditingController();

  List<SurahModel> allSurahs = [];
  List<SurahModel> filteredSurahs = [];

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _screenController;

  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _screenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );

    loadSurahs();
  }

  Future<void> loadSurahs() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final result = await quranService.getAllSurahs();

      if (!mounted) return;

      setState(() {
        allSurahs = result;
        filteredSurahs = result;
        isLoading = false;
      });

      _screenController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String normalizeArabic(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '');
  }

  void filterSurahs(String query) {
    final rawQuery = query.trim();
    final searchQuery = normalizeArabic(rawQuery);
    final englishQuery = rawQuery.toLowerCase();

    if (searchQuery.isEmpty) {
      setState(() {
        filteredSurahs = allSurahs;
      });

      return;
    }

    final results = allSurahs.where((surah) {
      final arabicName = normalizeArabic(surah.name);

      final englishName = surah.englishName.trim().toLowerCase();

      final translation = surah.englishNameTranslation.trim().toLowerCase();

      final number = surah.number.toString();

      return arabicName.contains(searchQuery) ||
          englishName.contains(englishQuery) ||
          translation.contains(englishQuery) ||
          number == rawQuery;
    }).toList();

    setState(() {
      filteredSurahs = results;
    });
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      filteredSurahs = allSurahs;
    });
  }

  void openSurah(SurahModel surah) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),

        pageBuilder: (context, animation, secondaryAnimation) {
          return SurahScreen(surah: surah);
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.10, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _screenController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,

        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                Icons.menu_book_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'القرآن الكريم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildHeroHeader(context),

                  const SizedBox(height: 16),

                  _buildSearchField(context),

                  const SizedBox(height: 12),

                  _buildResultInfo(context),
                ],
              ),
            ),

            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.primaryContainer, 0.45)!,
          ],
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),

              borderRadius: BorderRadius.circular(17),
            ),

            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'كتاب الله',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'اقرأ، تدبر، واطمئن',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '114 سورة • القرآن الكريم',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: searchController,

      onChanged: filterSurahs,

      textDirection: TextDirection.rtl,

      textInputAction: TextInputAction.search,

      decoration: InputDecoration(
        hintText: 'ابحث عن اسم السورة أو رقمها...',

        hintStyle: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),

        prefixIcon: Icon(Icons.search_rounded, color: colors.primary),

        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: clearSearch,

                icon: const Icon(Icons.close_rounded),
              )
            : null,

        filled: true,

        fillColor: colors.surface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildResultInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final bool isSearching = searchController.text.trim().isNotEmpty;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),

          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),

            borderRadius: BorderRadius.circular(10),
          ),

          child: Text(
            isSearching
                ? '${filteredSurahs.length} نتيجة'
                : '${allSurahs.length} سورة',

            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ),

        const Spacer(),

        if (isSearching)
          TextButton(
            onPressed: clearSearch,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'مسح البحث',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoading(context);
    }

    if (errorMessage != null) {
      return _buildError(context);
    }

    if (filteredSurahs.isEmpty) {
      return _buildEmpty(context);
    }

    return RefreshIndicator(
      onRefresh: loadSurahs,

      color: Theme.of(context).colorScheme.primary,

      backgroundColor: Theme.of(context).colorScheme.surface,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),

        itemCount: filteredSurahs.length,

        itemBuilder: (context, index) {
          final surah = filteredSurahs[index];

          final double delay = (index * 0.035).clamp(0.0, 0.55);

          return TweenAnimationBuilder<double>(
            key: ValueKey('${surah.number}_${searchController.text}'),

            tween: Tween<double>(begin: 0, end: 1),

            duration: const Duration(milliseconds: 500),

            curve: Curves.easeOutCubic,

            builder: (context, value, child) {
              final adjusted = (value - delay).clamp(0.0, 1.0);

              return Opacity(
                opacity: adjusted,

                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - adjusted)),

                  child: child,
                ),
              );
            },

            child: SurahItem(
              surah: surah,

              onTap: () {
                openSurah(surah);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),

      itemCount: 6,

      itemBuilder: (context, index) {
        return Container(
          height: 78,

          margin: const EdgeInsets.only(bottom: 10),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.25),
            ),
          ),

          child: Row(
            children: [
              const SizedBox(width: 14),

              _shimmerBox(context, width: 46, height: 46, radius: 14),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _shimmerBox(context, width: 90, height: 14, radius: 5),

                    const SizedBox(height: 8),

                    _shimmerBox(context, width: 130, height: 9, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(
    BuildContext context, {
    required double width,
    required double height,
    required double radius,
  }) {
    final colors = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.75),

      duration: const Duration(milliseconds: 900),

      curve: Curves.easeInOut,

      onEnd: () {},

      builder: (context, value, child) {
        return Opacity(
          opacity: value,

          child: Container(
            width: width,
            height: height,

            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.07),

              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 82,
              height: 82,

              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: colors.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'تعذر تحميل السور',

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'تحقق من اتصال الإنترنت وحاول مرة أخرى.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: loadSurahs,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 84,
              height: 84,

              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'لم نجد سورة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'جرّب اسم السورة أو رقمها.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: clearSearch,

              icon: const Icon(Icons.clear_rounded, size: 18),

              label: const Text('مسح البحث'),
            ),
          ],
        ),
      ),
    );
  }
}
