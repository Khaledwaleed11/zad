import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/hadith_grade_badge.dart';
import '../widgets/hadith_loading_widget.dart';
import '../widgets/hadith_narrators_section.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
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
      ),
      body: BlocConsumer<HadithCubit, HadithState>(
        listener: (context, state) {
          if (state.selectedHadith != null && !state.isLoadingDetails) {
            _animationController.forward(from: 0);
          }
        },
        builder: (context, state) {
          if (state.isLoadingDetails) {
            return const HadithLoadingWidget();
          }

          if (state.errorMessage != null && state.selectedHadith == null) {
            return _buildError(context, state.errorMessage!);
          }

          final hadith = state.selectedHadith;

          if (hadith == null) {
            return const SizedBox.shrink();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                children: [
                  _buildHeader(context, hadith.bookTitle),

                  const SizedBox(height: 18),

                  Center(child: HadithGradeBadge(grade: hadith.grade.label)),

                  const SizedBox(height: 20),

                  HadithTextCard(
                    title: 'نص الحديث',
                    text: hadith.fullText.isNotEmpty
                        ? hadith.fullText
                        : hadith.text,
                  ),

                  if (hadith.chapter.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    HadithTextCard(title: 'الباب', text: hadith.chapter),
                  ],

                  if (hadith.gradeNote.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    HadithTextCard(title: 'حكم الحديث', text: hadith.gradeNote),
                  ],

                  if (hadith.chain.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    HadithTextCard(title: 'السند', text: hadith.chain),
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String bookTitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: innerPaper,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: lightGold),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.auto_awesome,
                color: gold.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Icon(
                Icons.auto_awesome,
                color: gold.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
            Column(
              children: [
                Icon(Icons.menu_book_rounded, color: gold, size: 34),
                const SizedBox(height: 12),
                Text(
                  'من كتب السنة النبوية',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  bookTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 55,
                  height: 2,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
