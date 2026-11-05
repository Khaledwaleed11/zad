import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/memorization_test_config_entity.dart';
import '../cubit/memorization_test_cubit.dart';
import 'memorization_test_screen.dart';
import 'memorization_test_setup_screen.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/surah_entity.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import 'surah_screen.dart';
import '../widgets/memorization_test_banner.dart';
import '../widgets/quran_app_bar.dart';
import '../widgets/quran_hero_header.dart';
import '../widgets/quran_reciter_selector.dart';
import '../widgets/quran_search_field.dart';
import '../widgets/quran_result_info.dart';
import '../widgets/quran_surah_list.dart';
import '../widgets/quran_loading_view.dart';
import '../widgets/quran_error_view.dart';
import '../widgets/quran_empty_view.dart';
import '../widgets/quran_reciters_bottom_sheet.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late final QuranCubit quranCubit;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

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

  Future<void> openMemorizationTestSetup() async {
    searchFocusNode.unfocus();

    final config = await Navigator.push<MemorizationTestConfigEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => MemorizationTestSetupScreen(
          surahs: quranCubit.state.surahs,
        ),
      ),
    );

    if (!mounted || config == null) return;

    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        maintainState: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider(
            create: (_) => sl<MemorizationTestCubit>()
              ..startTest(config: config),
            child: const MemorizationTestScreen(),
          );
        },
      ),
    );
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
    await QuranRecitersBottomSheet.show(context, quranCubit);
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      filteredSurahs = quranCubit.state.surahs;
    });
  }

  void openSurah(SurahEntity surah) {
    searchFocusNode.unfocus();

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
    searchFocusNode.dispose();
    _screenController.dispose();
    quranCubit.close();
    super.dispose();
  }

  // Scrollable AppBar with the same screen background color.
  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Theme(
        data: theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        child: const QuranAppBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<QuranCubit, QuranState>(
      bloc: quranCubit,
      listenWhen: (previous, current) =>
          previous.surahsStatus != current.surahsStatus &&
          current.surahsStatus == QuranRequestStatus.success,
      listener: (context, state) {
        filteredSurahs = state.surahs;
        _screenController.forward(from: 0);
      },
      buildWhen: (previous, current) {
        return previous.surahsStatus != current.surahsStatus ||
            previous.surahs != current.surahs ||
            previous.recitersStatus != current.recitersStatus ||
            previous.reciters != current.reciters ||
            previous.selectedReciter != current.selectedReciter;
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: loadSurahs,
            color: colors.primary,
            backgroundColor: colors.surface,
            displacement: 45,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildSliverAppBar(context),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const QuranHeroHeader(),
                          const SizedBox(height: 13),
                          MemorizationTestBanner(
                            onTap: openMemorizationTestSetup,
                          ),
                          const SizedBox(height: 13),
                          QuranReciterSelector(
                            reciterName:
                                state.selectedReciter?.name ?? 'اختر القارئ',
                            recitersStatus: state.recitersStatus,
                            onTap: showRecitersBottomSheet,
                          ),

                          const SizedBox(height: 15),

                          QuranSearchField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            onChanged: filterSurahs,
                            onClear: clearSearch,
                          ),

                          const SizedBox(height: 11),

                          QuranResultInfo(
                            resultCount: searchController.text.trim().isNotEmpty
                                ? filteredSurahs.length
                                : state.surahs.length,
                            isSearching: searchController.text
                                .trim()
                                .isNotEmpty,
                            onClear: clearSearch,
                          ),
                        ],
                      ),
                    ),
                  ),

                  ..._buildContentSlivers(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildContentSlivers(QuranState state) {
    if (state.surahsStatus == QuranRequestStatus.loading ||
        state.surahsStatus == QuranRequestStatus.initial) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: QuranLoadingView(),
        ),
      ];
    }

    if (state.surahsStatus == QuranRequestStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: QuranErrorView(onRetry: loadSurahs),
        ),
      ];
    }

    if (filteredSurahs.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: QuranEmptyView(onClear: clearSearch),
        ),
      ];
    }

    return [
      QuranSurahList(
        surahs: filteredSurahs,
        searchQuery: searchController.text,
        onSurahTap: openSurah,
      ),
    ];
  }
}
