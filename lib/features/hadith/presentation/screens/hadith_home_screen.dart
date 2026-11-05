
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/hadith_loading_widget.dart';
import '../widgets/hadith_of_the_day_card.dart';
import '../widgets/hadith_source_info.dart';
import 'hadith_details_screen.dart';
import 'hadith_library_screen.dart';

class HadithHomeScreen extends StatefulWidget {
  const HadithHomeScreen({super.key});

  @override
  State<HadithHomeScreen> createState() => _HadithHomeScreenState();
}

class _HadithHomeScreenState extends State<HadithHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    _contentSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<HadithCubit>().loadHadithOfTheDay();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLibrary() {
    final hadithCubit = context.read<HadithCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: hadithCubit,
          child: const HadithLibraryScreen(),
        ),
      ),
    );
  }

  void _openDetails(String apiUrl) {
    final hadithCubit = context.read<HadithCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: hadithCubit,
          child: HadithDetailsScreen(apiUrl: apiUrl),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      pinned: false,
      floating: false,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFA88746).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6BE83),
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 19,
              color: Color(0xFFA88746),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'الأحاديث النبوية',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'مكتبة الأحاديث',
          icon: const Icon(Icons.library_books_outlined),
          onPressed: _openLibrary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<HadithCubit, HadithState>(
        listener: (context, state) {
          if (state.hadithOfTheDay != null) {
            _pageController.forward(from: 0);
          }
        },
        builder: (context, state) {
          if (state.isLoadingDaily && state.hadithOfTheDay == null) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: HadithLoadingWidget(),
                ),
              ],
            );
          }

          if (state.errorMessage != null &&
              state.hadithOfTheDay == null) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildError(colors, state.errorMessage!),
                ),
              ],
            );
          }

          final hadith = state.hadithOfTheDay;

          if (hadith == null) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox.shrink(),
                ),
              ],
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeader(context),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            HadithOfTheDayCard(
                              hadith: hadith,
                              isLoading: state.isLoadingDaily,
                              onAnotherHadith: () {
                                context
                                    .read<HadithCubit>()
                                    .loadAnotherHadith();
                              },
                            ),
                            const SizedBox(height: 16),
                            if (state.errorMessage != null)
                              _buildInlineError(
                                colors,
                                state.errorMessage!,
                              ),
                            HadithSourceInfo(
                              source: hadith.source,
                              license: hadith.license,
                              link: hadith.link,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailsButton(
                              colors,
                              hadith.book,
                              hadith.seq,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final paper = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGold),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.auto_awesome,
                size: 17,
                color: gold.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: Icon(
                Icons.auto_awesome,
                size: 17,
                color: gold.withValues(alpha: 0.55),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 20, 17, 18),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lightGold),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 27,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'من هدي النبي ﷺ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'حديث اليوم',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'نور من السنة النبوية يرافق يومك',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: gold.withValues(alpha: 0.65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsButton(
      ColorScheme colors,
      String book,
      int seq,
      ) {
    final gold = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _openDetails(
            'https://bayan.alwa7i.com/api/hadith/$book/$seq',
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: BorderSide(
            color: gold.withValues(alpha: 0.65),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.menu_book_outlined),
        label: const Text(
          'عرض تفاصيل الحديث',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildInlineError(
      ColorScheme colors,
      String message,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onErrorContainer,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildError(
      ColorScheme colors,
      String message,
      ) {
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
                Icons.error_outline_rounded,
                size: 40,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل الحديث',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context.read<HadithCubit>().loadHadithOfTheDay();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
