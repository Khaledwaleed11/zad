import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/responsive.dart';
import '../../domain/entities/prophet_story_section_entity.dart';
import '../cubit/prophets_stories_cubit.dart';
import '../cubit/prophets_stories_state.dart';
import '../widgets/prophets_stories_state_views.dart';

class ProphetStoryReaderScreen extends StatelessWidget {
  final ProphetStorySectionEntity section;

  const ProphetStoryReaderScreen({super.key, required this.section});

  Uri get _sourceUri {
    final page = section.pageTitle.replaceAll(' ', '_');
    return Uri.https('ar.wikisource.org', '/wiki/$page');
  }

  Future<void> _openSource() async {
    await launchUrl(_sourceUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    return Scaffold(
      backgroundColor: paper,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: paper,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          section.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ResponsiveBody(
        child: BlocBuilder<ProphetsStoriesCubit, ProphetsStoriesState>(
          builder: (context, state) {
            if (state.contentStatus == ProphetStoryContentStatus.loading ||
                state.contentStatus == ProphetStoryContentStatus.initial) {
              return const ProphetStoriesLoadingView(
                message: 'جاري تحميل القصة...',
              );
            }

            if (state.contentStatus == ProphetStoryContentStatus.failure) {
              return ProphetStoriesErrorView(
                message: state.contentErrorMessage ?? 'تعذر تحميل نص القصة.',
                onRetry: () => context
                    .read<ProphetsStoriesCubit>()
                    .loadStoryContent(section),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold, width: 1.2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: innerPaper,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: lightGold.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: gold, size: 21),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'قصص الأنبياء لابن كثير • ${section.volumeTitle}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 11,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                    child: SelectableText(
                      state.content ?? '',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        height: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(
                    color: innerPaper,
                    border: Border(top: BorderSide(color: lightGold)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'المصدر: قصص الأنبياء لابن كثير، ويكي مصدر',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: _openSource,
                        style: TextButton.styleFrom(
                          foregroundColor: gold,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('فتح المصدر الأصلي • CC BY-SA 4.0'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
