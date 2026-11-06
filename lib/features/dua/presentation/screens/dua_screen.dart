import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/zad_loading_widget.dart';
import '../../domain/entities/dua_category_entity.dart';
import '../cubit/written_dua_cubit.dart';
import '../cubit/written_dua_state.dart';
import '../widgets/dua_app_bar.dart';
import '../widgets/dua_content.dart';
import '../widgets/dua_details_sheet.dart';
import '../widgets/dua_error_view.dart';
import '../widgets/dua_filters.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WrittenDuaCubit>()..loadInitialData(),
      child: const _DuaView(),
    );
  }
}

class _DuaView extends StatefulWidget {
  const _DuaView();

  @override
  State<_DuaView> createState() => _DuaViewState();
}

class _DuaViewState extends State<_DuaView> {
  final TextEditingController _searchController = TextEditingController();

  bool _showFavoritesOnly = false;

  static const String _allCategory = '';
  static const String _favoritesCategory = '__favorites__';

  static const Map<String, String> _categoryNames = {
    'morning-and-evening': 'أذكار الصباح والمساء',
    'sleep-and-waking': 'النوم والاستيقاظ',
    'prayer-and-the-masjid': 'الصلاة والمسجد',
    'wudu-and-purification': 'الوضوء والطهارة',
    'food-and-drink': 'الطعام والشراب',
    'fasting': 'الصيام',
    'home-and-family': 'المنزل والأسرة',
    'travel': 'السفر',
    'hajj-and-umrah': 'الحج والعمرة',
    'weather-and-nature': 'الطقس والطبيعة',
    'distress-and-anxiety': 'الهم والضيق',
    'illness-and-healing': 'المرض والشفاء',
    'protection-and-refuge': 'الحفظ والاستعاذة',
    'forgiveness-and-repentance': 'الاستغفار والتوبة',
    'provision-and-debt': 'الرزق وقضاء الديون',
    'knowledge-and-guidance': 'العلم والهداية',
    'gatherings-and-greetings': 'المجالس والتحيات',
    'death-and-the-deceased': 'الموت والجنائز',
    'dhikr-and-praise': 'الذكر والثناء',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryName(String id) {
    return _categoryNames[id] ?? 'أدعية متنوعة';
  }

  String _getSelectedCategoryName(
    List<DuaCategoryEntity> categories,
    String selectedValue,
  ) {
    if (selectedValue == _favoritesCategory) {
      return 'المفضلة';
    }

    if (selectedValue == _allCategory) {
      return 'كل الأدعية';
    }

    final category = categories.where((item) => item.id == selectedValue);

    if (category.isEmpty) {
      return 'أدعية متنوعة';
    }

    return _getCategoryName(category.first.id);
  }

  Future<void> _showCategoryPicker({
    required BuildContext context,
    required WrittenDuaState state,
    required String selectedValue,
    required Color paper,
    required Color innerPaper,
    required Color gold,
    required Color lightGold,
    required Color textColor,
    required Color mutedColor,
  }) async {
    final options = <MapEntry<String, String>>[
      const MapEntry(_allCategory, 'كل الأدعية'),
      const MapEntry(_favoritesCategory, 'المفضلة'),
      ...state.categories.map(
        (category) => MapEntry(category.id, _getCategoryName(category.id)),
      ),
    ];

    final result = await DuaCategoryPickerSheet.show(
      context: context,
      options: options,
      selectedValue: selectedValue,
      paper: paper,
      innerPaper: innerPaper,
      gold: gold,
      lightGold: lightGold,
      textColor: textColor,
      mutedColor: mutedColor,
    );

    if (!context.mounted || result == null || result == selectedValue) {
      return;
    }

    setState(() {
      _showFavoritesOnly = result == _favoritesCategory;
    });

    if (result != _favoritesCategory) {
      context.read<WrittenDuaCubit>().selectCategory(
        result == _allCategory ? null : result,
      );
    }
  }

  void _onSearchChanged(String value) {
    context.read<WrittenDuaCubit>().search(value);
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<WrittenDuaCubit>().search('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);
    const lightGold = Color(0xFFD6BE83);
    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);
    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);
    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);
    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFEDE2C7);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ResponsiveBody(
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<WrittenDuaCubit, WrittenDuaState>(
              builder: (context, state) {
                if (state.status == WrittenDuaStatus.loading ||
                    state.status == WrittenDuaStatus.initial) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const DuaAppBar(),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.65,
                          child: const ZadLoadingWidget(
                            type: ZadLoadingType.dua,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.status == WrittenDuaStatus.failure) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const DuaAppBar(),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.65,
                          child: DuaErrorView(
                            onRetry: () {
                              context.read<WrittenDuaCubit>().loadInitialData();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final duas = _showFavoritesOnly
                    ? state.duas
                          .where((dua) => state.favoriteIds.contains(dua.id))
                          .toList()
                    : state.duas;
                final selectedValue = _showFavoritesOnly
                    ? _favoritesCategory
                    : state.selectedCategoryId ?? _allCategory;
                final selectedCategoryName = _getSelectedCategoryName(
                  state.categories,
                  selectedValue,
                );

                return DuaContent(
                  searchController: _searchController,
                  duas: duas,
                  favoriteIds: state.favoriteIds,
                  showFavoritesOnly: _showFavoritesOnly,
                  isDark: isDark,
                  isFavoritesSelected: selectedValue == _favoritesCategory,
                  selectedCategoryName: selectedCategoryName,
                  gold: gold,
                  lightGold: lightGold,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  paper: paper,
                  innerPaper: innerPaper,
                  onSearchChanged: _onSearchChanged,
                  onClearSearch: _clearSearch,
                  onCategoryTap: () => _showCategoryPicker(
                    context: context,
                    state: state,
                    selectedValue: selectedValue,
                    paper: paper,
                    innerPaper: innerPaper,
                    gold: gold,
                    lightGold: lightGold,
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  onDuaTap: (dua) {
                    DuaDetailsSheet.show(
                      context: context,
                      dua: dua,
                      gold: gold,
                      textColor: textColor,
                      mutedColor: mutedColor,
                    );
                  },
                  onFavoriteTap: (dua) {
                    context.read<WrittenDuaCubit>().toggleFavorite(dua.id);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
