import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/hadith_grade_badge.dart';
import '../widgets/hadith_loading_widget.dart';
import '../widgets/hadith_narrators_section.dart';
import '../widgets/hadith_screen_headers.dart';
import '../widgets/hadith_source_info.dart';
import '../widgets/hadith_text_card.dart';

class HadithDetailsScreen extends StatefulWidget {
  final String apiUrl;

  const HadithDetailsScreen({super.key, required this.apiUrl});

  @override
  State<HadithDetailsScreen> createState() => _HadithDetailsScreenState();
}

class _HadithDetailsScreenState extends State<HadithDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HadithCubit>().loadHadithDetails(widget.apiUrl);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.onSurface,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      floating: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFA88746).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFD6BE83)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFFA88746),
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'تفاصيل الحديث',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveBody(
        child: BlocConsumer<HadithCubit, HadithState>(
          listener: (context, state) {
            if (state.selectedHadith != null && !state.isLoadingDetails) {
              _animationController.forward(from: 0);
            }
          },
          builder: (context, state) {
            if (state.isLoadingDetails) {
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

            if (state.errorMessage != null && state.selectedHadith == null) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildError(context, state.errorMessage!),
                  ),
                ],
              );
            }

            final hadith = state.selectedHadith;

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
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildHeader(context, hadith.bookTitle),
                            const SizedBox(height: 18),
                            Center(
                              child: HadithGradeBadge(
                                grade: hadith.grade.label,
                              ),
                            ),
                            const SizedBox(height: 20),
                            HadithTextCard(
                              title: 'نص الحديث',
                              text: hadith.fullText.isNotEmpty
                                  ? hadith.fullText
                                  : hadith.text,
                            ),
                            if (hadith.chapter.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              HadithTextCard(
                                title: 'الباب',
                                text: hadith.chapter,
                              ),
                            ],
                            if (hadith.gradeNote.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              HadithTextCard(
                                title: 'حكم الحديث',
                                text: hadith.gradeNote,
                              ),
                            ],
                            if (hadith.chain.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              HadithTextCard(
                                title: 'السند',
                                text: hadith.chain,
                              ),
                            ],
                            const SizedBox(height: 16),
                            HadithNarratorsSection(narrators: hadith.narrators),
                            const SizedBox(height: 16),
                            HadithSourceInfo(
                              source: hadith.source,
                              license: hadith.license,
                              link: hadith.link,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String bookTitle) {
    return HadithBookHeader(bookTitle: bookTitle);
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                color: colors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تعذر تحميل تفاصيل الحديث',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context.read<HadithCubit>().loadHadithDetails(widget.apiUrl);
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
