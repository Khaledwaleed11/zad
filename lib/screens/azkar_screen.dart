import 'package:flutter/material.dart';

import '../models/azkar_model.dart';
import '../services/azkar_service.dart';
import '../widgets/zikr_card.dart';

class AzkarScreen extends StatefulWidget {
  final String initialCategory;

  const AzkarScreen({super.key, this.initialCategory = 'morning'});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with TickerProviderStateMixin {
  final AzkarService azkarService = AzkarService();

  List<AzkarModel> allAzkar = [];

  late String selectedCategory;

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _pageController;
  late AnimationController _categoryController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _headerSlide;
  late Animation<Offset> _chipsSlide;

  @override
  void initState() {
    super.initState();

    selectedCategory = _normalizeCategory(widget.initialCategory);

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.00, 0.35, curve: Curves.easeOutCubic),
          ),
        );

    _chipsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.20, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _categoryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    loadAzkar();
  }

  String _normalizeCategory(String category) {
    switch (category) {
      case 'morning':
        return 'morning';
      case 'evening':
        return 'evening';
      case 'sleep':
        return 'sleep';
      default:
        return 'morning';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> loadAzkar() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await azkarService.getAzkar();

      if (!mounted) return;

      setState(() {
        allAzkar = result;
        isLoading = false;
      });

      _pageController.forward(from: 0);
      _categoryController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<AzkarModel> get filteredAzkar {
    return allAzkar.where((zekr) => zekr.category == selectedCategory).toList();
  }

  void changeCategory(String category) {
    if (selectedCategory == category) {
      return;
    }

    setState(() {
      selectedCategory = category;
    });

    _categoryController.forward(from: 0);
  }

  String getCategoryTitle() {
    switch (selectedCategory) {
      case 'morning':
        return 'أذكار الصباح';

      case 'evening':
        return 'أذكار المساء';

      case 'sleep':
        return 'أذكار النوم';

      default:
        return 'الأذكار';
    }
  }

  String getCategoryDescription() {
    switch (selectedCategory) {
      case 'morning':
        return 'ابدأ يومك بذكر الله';

      case 'evening':
        return 'اختم يومك بذكر الله';

      case 'sleep':
        return 'اختم يومك بالذكر والطمأنينة';

      default:
        return 'اذكر الله وطمئن قلبك';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'الأذكار',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, colors),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colors) {
    if (isLoading) {
      return _buildLoading(colors);
    }

    if (errorMessage != null) {
      return _buildError(colors);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(context, colors),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _chipsSlide,
                    child: _buildCategories(colors),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.10),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Align(
                    key: ValueKey(selectedCategory),
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${getCategoryDescription()} • ${filteredAzkar.length} أذكار',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        if (filteredAzkar.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmpty(colors))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: _buildAzkarSliver(),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(selectedCategory),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.primaryContainer, 0.45)!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.14),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ذكر الله حياة للقلوب',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getCategoryTitle(),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getCategoryDescription(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.auto_awesome_rounded,
              size: 19,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(ColorScheme colors) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryChip(
            title: 'أذكار الصباح',
            value: 'morning',
            isSelected: selectedCategory == 'morning',
            onTap: () {
              changeCategory('morning');
            },
          ),
          _buildCategoryChip(
            title: 'أذكار المساء',
            value: 'evening',
            isSelected: selectedCategory == 'evening',
            onTap: () {
              changeCategory('evening');
            },
          ),
          _buildCategoryChip(
            title: 'أذكار النوم',
            value: 'sleep',
            isSelected: selectedCategory == 'sleep',
            onTap: () {
              changeCategory('sleep');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final zekr = filteredAzkar[index];

        final double startDelay = (index * 0.035).clamp(0.0, 0.45);

        return TweenAnimationBuilder<double>(
          key: ValueKey('${selectedCategory}_${zekr.id}'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final adjustedValue = ((value - startDelay) / (1 - startDelay))
                .clamp(0.0, 1.0);

            return Opacity(
              opacity: adjustedValue,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - adjustedValue)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ZikrCard(key: ValueKey(zekr.id), zekr: zekr),
          ),
        );
      }, childCount: filteredAzkar.length),
    );
  }

  Widget _buildCategoryChip({
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value == 'morning'
                        ? Icons.wb_sunny_outlined
                        : value == 'evening'
                        ? Icons.nights_stay_outlined
                        : Icons.bedtime_outlined,
                    size: 17,
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تجهيز الأذكار...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لحظات ونبدأ معك',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme colors) {
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
              'تعذر تحميل الأذكار',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حدثت مشكلة أثناء قراءة بيانات الأذكار.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: loadAzkar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 38,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أذكار هنا',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'جرّب قسمًا آخر من الأذكار.',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
