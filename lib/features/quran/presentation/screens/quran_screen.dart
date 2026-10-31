import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad/features/quran/presentation/screens/surah_screen.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/surah_entity.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/surah_item.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final QuranCubit quranCubit;

  final TextEditingController searchController = TextEditingController();

  List<SurahEntity> filteredSurahs = [];

  late AnimationController _screenController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    quranCubit = sl<QuranCubit>();

    _screenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );

    quranCubit.loadSurahs();
    quranCubit.loadReciters();
  }

  Future<void> loadSurahs() async {
    await quranCubit.loadSurahs();
  }

  Future<void> loadReciters() async {
    await quranCubit.loadReciters();
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
    final allSurahs = quranCubit.state.surahs;

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

  Future<void> showRecitersBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colors = Theme.of(bottomSheetContext).colorScheme;

        return BlocBuilder<QuranCubit, QuranState>(
          bloc: quranCubit,
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.65),
                  width: 1.2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(23),
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                        child: Row(
                          children: [
                            _buildIconContainer(
                              colors,
                              Icons.record_voice_over_rounded,
                              size: 42,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'اختر القارئ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              '${state.reciters.length} قارئ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: colors.primary.withValues(alpha: 0.22),
                      ),
                      Expanded(child: _buildRecitersList(context, state)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecitersList(BuildContext context, QuranState state) {
    final colors = Theme.of(context).colorScheme;

    if (state.recitersStatus == QuranRequestStatus.loading ||
        state.recitersStatus == QuranRequestStatus.initial) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.recitersStatus == QuranRequestStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 42, color: colors.error),
              const SizedBox(height: 12),
              Text(
                'تعذر تحميل القرّاء',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: loadReciters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reciters.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد قرّاء متاحون حاليًا',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: state.reciters.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: colors.primary.withValues(alpha: 0.15)),
      itemBuilder: (context, index) {
        final reciter = state.reciters[index];
        final isSelected =
            state.selectedReciter?.identifier == reciter.identifier;

        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            onTap: () async {
              await quranCubit.selectReciter(reciter);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(Icons.person_rounded, color: colors.primary),
            ),
            title: Text(
              reciter.name,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            subtitle: reciter.englishName == null
                ? null
                : Text(
                    reciter.englishName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? colors.primary : colors.outlineVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReciterSelector(BuildContext context, QuranState state) {
    final colors = Theme.of(context).colorScheme;

    final reciterName = state.selectedReciter?.name ?? 'اختر القارئ';

    return InkWell(
      onTap: showRecitersBottomSheet,
      borderRadius: BorderRadius.circular(18),
      child: _buildFramedContainer(
        colors: colors,
        padding: const EdgeInsets.all(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              _buildIconContainer(
                colors,
                Icons.record_voice_over_rounded,
                size: 40,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القارئ الحالي',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reciterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (state.recitersStatus == QuranRequestStatus.loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              else if (state.recitersStatus == QuranRequestStatus.failure)
                Icon(Icons.refresh_rounded, color: colors.error)
              else
                Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      filteredSurahs = quranCubit.state.surahs;
    });
  }

  void openSurah(SurahEntity surah) {
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
    quranCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<QuranCubit, QuranState>(
      bloc: quranCubit,
      listener: (context, state) {
        if (state.surahsStatus == QuranRequestStatus.success) {
          filteredSurahs = state.surahs;
          _screenController.forward(from: 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(colors),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroHeader(context),
                      const SizedBox(height: 13),
                      _buildReciterSelector(context, state),
                      const SizedBox(height: 15),
                      _buildSearchField(context),
                      const SizedBox(height: 11),
                      _buildResultInfo(context),
                    ],
                  ),
                ),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  // AppBar

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'القرآن الكريم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 1,
                color: colors.primary.withValues(alpha: 0.6),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.auto_awesome,
                  size: 11,
                  color: colors.primary,
                ),
              ),
              Container(
                width: 22,
                height: 1,
                color: colors.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.menu_book_rounded, size: 20, color: colors.primary),
        ),
      ),
    );
  }

  // Hero Header

  Widget _buildHeroHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _buildFramedContainer(
      colors: colors,
      padding: const EdgeInsets.all(5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.11),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: colors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كتاب الله',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اقرأ، تدبر، واطمئن',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '114 سورة • القرآن الكريم',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.auto_awesome,
              color: colors.primary.withValues(alpha: 0.55),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // Search

  Widget _buildSearchField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: filterSurahs,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن اسم السورة أو رقمها...',
          hintStyle: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 21,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: clearSearch,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.primary,
                    size: 19,
                  ),
                )
              : null,
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: colors.primary, width: 1),
          ),
        ),
      ),
    );
  }

  // Result Info

  Widget _buildResultInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isSearching = searchController.text.trim().isNotEmpty;

    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 13,
          color: colors.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          isSearching
              ? '${filteredSurahs.length} نتيجة'
              : '${quranCubit.state.surahs.length} سورة',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: colors.onSurfaceVariant,
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

  // Content

  Widget _buildContent(BuildContext context, QuranState state) {
    if (state.surahsStatus == QuranRequestStatus.loading ||
        state.surahsStatus == QuranRequestStatus.initial) {
      return _buildLoading(context);
    }

    if (state.surahsStatus == QuranRequestStatus.failure) {
      return _buildError(context);
    }

    if (filteredSurahs.isEmpty) {
      return _buildEmpty(context);
    }

    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: loadSurahs,
      color: colors.primary,
      backgroundColor: colors.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
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
            child: _buildSurahFrame(colors, surah),
          );
        },
      ),
    );
  }

  Widget _buildSurahFrame(ColorScheme colors, SurahEntity surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.45),
          width: 0.9,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.20),
            width: 0.7,
          ),
        ),
        child: SurahItem(
          surah: surah,
          onTap: () {
            openSurah(surah);
          },
        ),
      ),
    );
  }

  // Loading

  Widget _buildLoading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 78,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _shimmerBox(context, width: 44, height: 44, radius: 13),
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
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  // Error

  Widget _buildError(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(
              colors,
              Icons.cloud_off_rounded,
              size: 78,
              iconSize: 35,
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
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: loadSurahs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty Search

  Widget _buildEmpty(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(
              colors,
              Icons.search_off_rounded,
              size: 78,
              iconSize: 35,
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

  // Reusable Design Helpers

  Widget _buildFramedContainer({
    required ColorScheme colors,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(4),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.65),
          width: 1.1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildIconContainer(
    ColorScheme colors,
    IconData icon, {
    double size = 42,
    double iconSize = 21,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: colors.primary, size: iconSize),
    );
  }
}
