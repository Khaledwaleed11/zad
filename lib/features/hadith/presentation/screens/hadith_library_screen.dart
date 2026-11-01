import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/hadith_loading_widget.dart';
import '../widgets/hadith_search_field.dart';
import '../widgets/hadith_search_result_card.dart';
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
      appBar: AppBar(
        backgroundColor: paperColor,
        elevation: 0,
        centerTitle: true,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: innerPaperColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withValues(alpha: isDark ? 0.04 : 0.08),
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
              const SizedBox(height: 18),
              HadithSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (query) {
                  setState(() {});
                  context.read<HadithCubit>().search(query);
                },
                onClear: _clearSearch,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<HadithCubit, HadithState>(
                  builder: (context, state) {
                    if (state.isLoadingSearch) {
                      return const HadithLoadingWidget(
                        message: 'جاري البحث عن الأحاديث...',
                      );
                    }

                    if (state.errorMessage != null &&
                        state.searchResults.isEmpty &&
                        _searchController.text.trim().isNotEmpty) {
                      return _buildMessage(
                        icon: Icons.error_outline_rounded,
                        title: 'تعذر إتمام البحث',
                        subtitle: state.errorMessage!,
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      );
                    }

                    if (_searchController.text.trim().isEmpty) {
                      return _buildMessage(
                        icon: Icons.search_rounded,
                        title: 'ابدأ البحث',
                        subtitle: 'ابحث عن حديث باستخدام كلمة أو عبارة',
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      );
                    }

                    if (state.searchResults.isEmpty) {
                      return _buildMessage(
                        icon: Icons.menu_book_outlined,
                        title: 'لا توجد نتائج',
                        subtitle: 'جرب البحث باستخدام كلمات مختلفة',
                        goldColor: goldColor,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      );
                    }

                    return ListView.builder(
                      itemCount: state.searchResults.length,
                      padding: const EdgeInsets.only(bottom: 12),
                      itemBuilder: (context, index) {
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
                      },
                    );
                  },
                ),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: goldColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: goldColor, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 13, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
