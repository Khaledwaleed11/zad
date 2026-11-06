import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/hadith_loading_widget.dart';
import '../widgets/hadith_search_field.dart';
import '../widgets/hadith_search_result_card.dart';
import '../widgets/hadith_status_message.dart';
import 'hadith_details_screen.dart';

class HadithLibraryScreen extends StatefulWidget {
  const HadithLibraryScreen({super.key});

  @override
  State<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends State<HadithLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<HadithCubit>().clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paperColor = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFF7F1DF);

    final innerPaperColor = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final goldColor = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return Scaffold(
      backgroundColor: paperColor,
      body: ResponsiveBody(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // AppBar
              SliverAppBar(
                backgroundColor: paperColor,
                surfaceTintColor: Colors.transparent,
                foregroundColor: textColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                pinned: false,
                floating: false,
                automaticallyImplyLeading: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.library_books_rounded,
                        color: goldColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'مكتبة الأحاديث',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // مقدمة البحث
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: innerPaperColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: goldColor.withValues(
                            alpha: isDark ? 0.04 : 0.08,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: goldColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ابحث في الأحاديث النبوية',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'اكتب كلمة أو عبارة للعثور على الأحاديث المرتبطة بها',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // حقل البحث
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: HadithSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (query) {
                      setState(() {});
                      context.read<HadithCubit>().search(query);
                    },
                    onClear: _clearSearch,
                  ),
                ),
              ),

              // نتائج البحث
              BlocBuilder<HadithCubit, HadithState>(
                builder: (context, state) {
                  if (state.isLoadingSearch) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: HadithLoadingWidget(
                        message: 'جاري البحث عن الأحاديث...',
                      ),
                    );
                  }

                  if (state.errorMessage != null &&
                      state.searchResults.isEmpty &&
                      _searchController.text.trim().isNotEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildMessage(
                        icon: Icons.error_outline_rounded,
                        title: 'تعذر إتمام البحث',
                        subtitle: state.errorMessage!,
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                    );
                  }

                  if (_searchController.text.trim().isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildMessage(
                        icon: Icons.search_rounded,
                        title: 'ابدأ البحث',
                        subtitle: 'ابحث عن حديث باستخدام كلمة أو عبارة',
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                    );
                  }

                  if (state.searchResults.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildMessage(
                        icon: Icons.menu_book_outlined,
                        title: 'لا توجد نتائج',
                        subtitle: 'جرب البحث باستخدام كلمات مختلفة',
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final hadith = state.searchResults[index];

                        return HadithSearchResultCard(
                          hadith: hadith,
                          onTap: () {
                            _searchFocusNode.unfocus();

                            final hadithCubit = context.read<HadithCubit>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: hadithCubit,
                                  child: HadithDetailsScreen(
                                    apiUrl: hadith.api,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }, childCount: state.searchResults.length),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color goldColor,
    required Color textColor,
    required Color mutedColor,
  }) {
    return HadithStatusMessage(
      icon: icon,
      title: title,
      subtitle: subtitle,
      goldColor: goldColor,
      textColor: textColor,
      mutedColor: mutedColor,
    );
  }
}
