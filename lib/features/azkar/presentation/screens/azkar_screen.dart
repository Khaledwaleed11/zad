
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/azkar_entity.dart';
import '../cubit/azkar_cubit.dart';
import '../cubit/azkar_state.dart';
import '../widgets/azkar_categories.dart';
import '../widgets/azkar_form_dialog.dart';
import '../widgets/azkar_header.dart';
import '../widgets/azkar_list.dart';
import '../widgets/azkar_state_views.dart';

class AzkarScreen extends StatefulWidget {
  final String initialCategory;

  const AzkarScreen({
    super.key,
    this.initialCategory = 'morning',
  });

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with TickerProviderStateMixin {
  late String selectedCategory;

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
        Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(
              0.00,
              0.35,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    _chipsSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(
              0.20,
              0.55,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

    _categoryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  String _normalizeCategory(String category) {
    switch (category) {
      case 'morning':
      case 'evening':
      case 'sleep':
      case 'custom':
        return category;
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

  List<AzkarEntity> filteredAzkar(List<AzkarEntity> allAzkar) {
    if (selectedCategory == 'custom') {
      return allAzkar.where((zekr) => zekr.isCustom).toList();
    }

    return allAzkar
        .where(
          (zekr) =>
      !zekr.isCustom && zekr.category == selectedCategory,
    )
        .toList();
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

  Future<void> _showAzkarForm(
      BuildContext context, {
        AzkarEntity? zekr,
      }) async {
    final result = await showDialog<AzkarEntity>(
      context: context,
      builder: (_) => AzkarFormDialog(zekr: zekr),
    );

    if (!mounted || result == null) return;

    final cubit = context.read<AzkarCubit>();

    if (zekr == null) {
      await cubit.addCustomZikr(result);
    } else {
      await cubit.updateCustomZikr(result);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          zekr == null ? 'تمت إضافة الذكر' : 'تم تعديل الذكر',
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAzkar(
      BuildContext context,
      AzkarEntity zekr,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الذكر'),
          content: const Text('هل أنت متأكد من حذف هذا الذكر؟'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await context.read<AzkarCubit>().deleteCustomZikr(zekr.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الذكر')),
    );
  }

  String getCategoryTitle() {
    switch (selectedCategory) {
      case 'morning':
        return 'أذكار الصباح';
      case 'evening':
        return 'أذكار المساء';
      case 'sleep':
        return 'أذكار النوم';
      case 'custom':
        return 'أذكاري';
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
      case 'custom':
        return 'الأذكار التي أضفتها بنفسك';
      default:
        return 'اذكر الله وطمئن قلبك';
    }
  }

  // Scrollable AppBar
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      floating: false,
      automaticallyImplyLeading: false,
      centerTitle: true,
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
              Icons.auto_awesome_rounded,
              size: 19,
              color: Color(0xFFA88746),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'الأذكار',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showAzkarForm(context),
          tooltip: 'إضافة ذكر',
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocProvider(
      create: (_) => sl<AzkarCubit>()..loadAzkar(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocConsumer<AzkarCubit, AzkarState>(
          listener: (context, state) {
            if (state.status == AzkarStatus.success) {
              _pageController.forward(from: 0);
              _categoryController.forward(from: 0);
            }
          },
          builder: (context, state) {
            return _buildBody(context, colors, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ColorScheme colors,
      AzkarState state,
      ) {
    if (state.status == AzkarStatus.initial ||
        state.status == AzkarStatus.loading) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AzkarLoadingView(colors: colors),
          ),
        ],
      );
    }

    if (state.status == AzkarStatus.failure) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AzkarErrorView(
              colors: colors,
              onRetry: () =>
                  context.read<AzkarCubit>().loadAzkar(),
            ),
          ),
        ],
      );
    }

    final azkar = filteredAzkar(state.azkar);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context),

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
                    child: AzkarHeader(
                      categoryTitle: getCategoryTitle(),
                      categoryDescription:
                      getCategoryDescription(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _chipsSlide,
                    child: AzkarCategories(
                      selectedCategory: selectedCategory,
                      onCategoryChanged: changeCategory,
                    ),
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
                          '${getCategoryDescription()} • ${azkar.length} أذكار',
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

        if (azkar.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AzkarEmptyView(colors: colors),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: AzkarList(
              azkar: azkar,
              selectedCategory: selectedCategory,
              onEdit: (zekr) =>
                  _showAzkarForm(context, zekr: zekr),
              onDelete: (zekr) =>
                  _confirmDeleteAzkar(context, zekr),
            ),
          ),
      ],
    );
  }
}
