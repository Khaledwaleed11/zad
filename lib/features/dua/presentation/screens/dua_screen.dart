import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/widgets/zad_loading_widget.dart';
import '../../domain/entities/dua_category_entity.dart';
import '../../domain/entities/written_dua_entity.dart';
import '../cubit/written_dua_cubit.dart';
import '../cubit/written_dua_state.dart';

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
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<WrittenDuaCubit, WrittenDuaState>(
            builder: (context, state) {
              if (state.status == WrittenDuaStatus.loading ||
                  state.status == WrittenDuaStatus.initial) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDuaAppBar(),
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
                      _buildDuaAppBar(),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.65,
                        child: _buildError(context),
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

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _buildDuaAppBar(),

                    // Search field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: paper,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: gold, width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(
                                alpha: isDark ? 0.06 : 0.11,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: lightGold.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: innerPaper,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: lightGold.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Stack(
                              children: [
                                ...[
                                  Alignment.topRight,
                                  Alignment.topLeft,
                                  Alignment.bottomRight,
                                  Alignment.bottomLeft,
                                ].map(
                                  (alignment) => Align(
                                    alignment: alignment,
                                    child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: gold.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      context.read<WrittenDuaCubit>().search(
                                        value,
                                      );
                                      setState(() {});
                                    },
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      hintText: 'ابحث عن دعاء...',
                                      hintStyle: TextStyle(color: mutedColor),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: gold,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                          ? IconButton(
                                              onPressed: () {
                                                _searchController.clear();
                                                context
                                                    .read<WrittenDuaCubit>()
                                                    .search('');
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color: mutedColor,
                                              ),
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Category selector
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: InkWell(
                        onTap: () => _showCategoryPicker(
                          context: context,
                          categories: state.categories,
                          selectedValue: selectedValue,
                          paper: paper,
                          innerPaper: innerPaper,
                          gold: gold,
                          lightGold: lightGold,
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                        borderRadius: BorderRadius.circular(17),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: paper,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gold, width: 1.4),
                            boxShadow: [
                              BoxShadow(
                                color: gold.withValues(
                                  alpha: isDark ? 0.06 : 0.11,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: lightGold.withValues(alpha: 0.8),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: innerPaper,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: lightGold.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  ...[
                                    Alignment.topRight,
                                    Alignment.topLeft,
                                    Alignment.bottomRight,
                                    Alignment.bottomLeft,
                                  ].map(
                                    (alignment) => Align(
                                      alignment: alignment,
                                      child: Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: Icon(
                                          Icons.auto_awesome,
                                          size: 14,
                                          color: gold.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 13,
                                    ),
                                    child: Row(
                                      children: [
                                        _buildPickerIcon(
                                          selectedValue == _favoritesCategory
                                              ? Icons.favorite_rounded
                                              : Icons.category_rounded,
                                          gold,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'التصنيف',
                                                style: TextStyle(
                                                  color: mutedColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                selectedCategoryName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: gold,
                                          size: 26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Dua list
                    if (duas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text(
                            _showFavoritesOnly
                                ? 'لا توجد أدعية في المفضلة'
                                : 'لا توجد أدعية',
                            style: TextStyle(color: mutedColor, fontSize: 15),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        itemCount: duas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final dua = duas[index];

                          return _buildDuaCard(
                            context: context,
                            dua: dua,
                            isFavorite: state.favoriteIds.contains(dua.id),
                            gold: gold,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            paper: paper,
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDuaAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFA88746).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6BE83)),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 19,
              color: Color(0xFFA88746),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'الأدعية',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
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

  Widget _buildDuaCard({
    required BuildContext context,
    required WrittenDuaEntity dua,
    required bool isFavorite,
    required Color gold,
    required Color textColor,
    required Color mutedColor,
    required Color paper,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: isDark ? 0.06 : 0.11),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightGold.withValues(alpha: 0.8)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lightGold.withValues(alpha: 0.25)),
          ),
          child: Stack(
            children: [
              ...[
                Alignment.topRight,
                Alignment.topLeft,
                Alignment.bottomRight,
                Alignment.bottomLeft,
              ].map(
                (alignment) => Align(
                  alignment: alignment,
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: gold.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showDuaDetails(
                    context,
                    dua,
                    gold,
                    textColor,
                    mutedColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        SizedBox(
                          height: 38,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: lightGold),
                                  ),
                                  child: Text(
                                    '۞  الدعاء  ۞',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: gold,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    context
                                        .read<WrittenDuaCubit>()
                                        .toggleFavorite(dua.id);
                                  },
                                  tooltip: isFavorite
                                      ? 'إزالة من المفضلة'
                                      : 'إضافة للمفضلة',
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: isFavorite ? gold : mutedColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Divider(color: lightGold, height: 1),
                        const SizedBox(height: 18),

                        // Arabic dua
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            dua.arabicText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              height: 1.9,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Decorative divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: lightGold.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: gold,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: lightGold.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: lightGold.withValues(alpha: 0.65),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: gold,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'اضغط لقراءة الدعاء',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                              if (dua.repetitionCount != null) ...[
                                Text(
                                  'التكرار: ${dua.repetitionCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: mutedColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 13,
                                color: gold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker({
    required BuildContext context,
    required List<DuaCategoryEntity> categories,
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
      ...categories.map(
        (category) => MapEntry(category.id, _getCategoryName(category.id)),
      ),
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: gold.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: lightGold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Row(
                  children: [
                    _buildPickerIcon(Icons.category_rounded, gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر التصنيف',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر التصنيف الذي تريد عرض أدعيته',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
                  ],
                ),
              ),
              Divider(height: 1, color: lightGold.withValues(alpha: 0.35)),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option.key == selectedValue;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext, option.key);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? gold.withValues(alpha: 0.13)
                              : innerPaper,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? gold
                                : lightGold.withValues(alpha: 0.35),
                            width: isSelected ? 1.3 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: gold,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.value,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Text(
                                'الحالي',
                                style: TextStyle(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null || result == selectedValue) {
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

  Widget _buildPickerIcon(IconData icon, Color gold) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: gold, size: 22),
    );
  }

  void _showDuaDetails(
    BuildContext context,
    WrittenDuaEntity dua,
    Color gold,
    Color textColor,
    Color mutedColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paper = isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFEDE2C7);

    const lightGold = Color(0xFFD6BE83);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          decoration: BoxDecoration(
            color: paper,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: gold.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: lightGold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Row(
                  children: [
                    _buildPickerIcon(Icons.menu_book_rounded, gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نص الدعاء',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اقرأ الدعاء وانسخه بسهولة',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
                  ],
                ),
              ),
              Divider(height: 1, color: lightGold.withValues(alpha: 0.35)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: gold.withValues(alpha: 0.75)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: innerPaper,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lightGold.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        dua.arabicText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          height: 2.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dua.arabicText));

                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الدعاء')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('نسخ الدعاء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42),
          const SizedBox(height: 12),
          const Text('حدث خطأ أثناء تحميل الأدعية'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<WrittenDuaCubit>().loadInitialData();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
