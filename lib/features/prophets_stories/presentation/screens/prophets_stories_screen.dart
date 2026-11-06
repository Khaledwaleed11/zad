import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/prophet_story_section_entity.dart';
import '../cubit/prophets_stories_cubit.dart';
import '../cubit/prophets_stories_state.dart';
import '../widgets/prophet_story_section_card.dart';
import '../widgets/prophets_stories_state_views.dart';
import 'prophet_story_reader_screen.dart';

class ProphetsStoriesScreen extends StatelessWidget {
  const ProphetsStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProphetsStoriesCubit>()..loadSections(),
      child: const _ProphetsStoriesView(),
    );
  }
}

class _ProphetsStoriesView extends StatefulWidget {
  const _ProphetsStoriesView();

  @override
  State<_ProphetsStoriesView> createState() => _ProphetsStoriesViewState();
}

class _ProphetsStoriesViewState extends State<_ProphetsStoriesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStory(
    BuildContext context,
    ProphetsStoriesCubit cubit,
    ProphetStorySectionEntity section,
  ) {
    cubit.loadStoryContent(section);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ProphetStoryReaderScreen(section: section),
        ),
      ),
    );
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
          'قصص الأنبياء',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ResponsiveBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: innerPaper,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: lightGold.withValues(alpha: 0.75)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث في عناوين القصص',
                    hintStyle: TextStyle(color: mutedColor, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: gold),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: Icon(Icons.close_rounded, color: mutedColor),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProphetsStoriesCubit, ProphetsStoriesState>(
                builder: (context, state) {
                  if (state.status == ProphetStoriesStatus.loading ||
                      state.status == ProphetStoriesStatus.initial) {
                    return const ProphetStoriesLoadingView();
                  }

                  if (state.status == ProphetStoriesStatus.failure) {
                    return ProphetStoriesErrorView(
                      message: state.errorMessage ?? 'حدث خطأ غير متوقع.',
                      onRetry: () => context
                          .read<ProphetsStoriesCubit>()
                          .loadSections(forceRefresh: true),
                    );
                  }

                  final query = _searchQuery.trim().toLowerCase();
                  final sections = state.sections
                      .where(
                        (section) =>
                            section.title.toLowerCase().contains(query),
                      )
                      .toList(growable: false);

                  if (sections.isEmpty) {
                    return const ProphetStoriesEmptyView();
                  }

                  final cubit = context.read<ProphetsStoriesCubit>();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return ProphetStorySectionCard(
                        section: section,
                        onTap: () => _openStory(context, cubit, section),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
