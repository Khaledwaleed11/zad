import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/azkar_entity.dart';
import '../cubit/azkar_cubit.dart';
import '../cubit/azkar_state.dart';
import '../widgets/zikr_card.dart';

class AzkarScreen extends StatefulWidget {
  final String initialCategory;

  const AzkarScreen({super.key, this.initialCategory = 'morning'});

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
      builder: (_) => _AzkarFormDialog(zekr: zekr),
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
        content: Text(zekr == null ? 'تمت إضافة الذكر' : 'تم تعديل الذكر'),
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await context.read<AzkarCubit>().deleteCustomZikr(zekr.id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الذكر')));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocProvider(
      create: (_) => sl<AzkarCubit>()..loadAzkar(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
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
            Builder(
              builder: (context) => IconButton(
                onPressed: () => _showAzkarForm(context),
                tooltip: 'إضافة ذكر',
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
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
      return _buildLoading(colors);
    }

    if (state.status == AzkarStatus.failure) {
      return _buildError(colors);
    }

    final azkar = filteredAzkar(state.azkar);

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
          SliverFillRemaining(hasScrollBody: false, child: _buildEmpty(colors))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: _buildAzkarSliver(azkar),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final paper = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFF7F1DF);

    final innerPaper = isDark
        ? const Color(0xFF201B13)
        : const Color(0xFFFFFCF4);

    final gold = isDark
        ? const Color(0xFFD6BE83)
        : const Color(0xFFA88746);

    final lightGold = isDark
        ? const Color(0xFF806B43)
        : const Color(0xFFD6BE83);

    final textColor = isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF493A25);

    final mutedColor = isDark
        ? const Color(0xFFC1B18F)
        : const Color(0xFF786548);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(selectedCategory),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: innerPaper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: lightGold),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                right: 5,
                child: Icon(
                  Icons.auto_awesome,
                  size: 17,
                  color: gold.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Icon(
                  Icons.auto_awesome,
                  size: 17,
                  color: gold.withValues(alpha: 0.55),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 20, 17, 18),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: lightGold),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 27,
                        color: gold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ذكر الله حياة للقلوب',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            getCategoryTitle(),
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getCategoryDescription(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: gold.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            onTap: () => changeCategory('morning'),
          ),
          _buildCategoryChip(
            title: 'أذكار المساء',
            value: 'evening',
            isSelected: selectedCategory == 'evening',
            onTap: () => changeCategory('evening'),
          ),
          _buildCategoryChip(
            title: 'أذكار النوم',
            value: 'sleep',
            isSelected: selectedCategory == 'sleep',
            onTap: () => changeCategory('sleep'),
          ),
          _buildCategoryChip(
            title: 'أذكاري',
            value: 'custom',
            isSelected: selectedCategory == 'custom',
            onTap: () => changeCategory('custom'),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarSliver(List<AzkarEntity> azkar) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final zekr = azkar[index];

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
            child: ZikrCard(
              key: ValueKey(zekr.id),
              zekr: zekr,
              onEdit: () => _showAzkarForm(context, zekr: zekr),
              onDelete: () => _confirmDeleteAzkar(context, zekr),
            ),
          ),
        );
      }, childCount: azkar.length),
    );
  }

  Widget _buildCategoryChip({
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    const gold = Color(0xFFA88746);
    const lightGold = Color(0xFFD6BE83);

    final selectedColor = isDark
        ? const Color(0xFFD6BE83)
        : gold;

    final unselectedColor = isDark
        ? const Color(0xFF252017)
        : const Color(0xFFFFFCF4);

    final textColor = isSelected
        ? (isDark ? const Color(0xFF201B13) : Colors.white)
        : (isDark
        ? const Color(0xFFF2E8D2)
        : const Color(0xFF786548));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : lightGold,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: gold.withValues(alpha: 0.16),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value == 'morning'
                        ? Icons.wb_sunny_outlined
                        : value == 'evening'
                        ? Icons.nights_stay_outlined
                        : value == 'sleep'
                        ? Icons.bedtime_outlined
                        : Icons.bookmark_outline_rounded,
                    size: 17,
                    color: textColor,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textColor,
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
              onPressed: () => context.read<AzkarCubit>().loadAzkar(),
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
              'جرّب قسمًا آخر أو أضف ذكرًا جديدًا.',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

}
class _AzkarFormDialog extends StatefulWidget {
  final AzkarEntity? zekr;

  const _AzkarFormDialog({this.zekr});

  @override
  State<_AzkarFormDialog> createState() => _AzkarFormDialogState();
}

class _AzkarFormDialogState extends State<_AzkarFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.zekr?.title ?? '',
    );

    _textController = TextEditingController(
      text: widget.zekr?.text ?? '',
    );

    _countController = TextEditingController(
      text: widget.zekr?.count.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.zekr == null ? 'إضافة ذكر جديد' : 'تعديل الذكر',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'عنوان الذكر',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب عنوان الذكر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _textController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'نص الذكر',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب نص الذكر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد التكرار',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final count = int.tryParse(value ?? '');

                  if (count == null || count <= 0) {
                    return 'أدخل عددًا صحيحًا أكبر من صفر';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.zekr == null ? 'إضافة' : 'حفظ'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      AzkarEntity(
        id: widget.zekr?.id ?? 0,
        category: 'custom',
        title: _titleController.text.trim(),
        text: _textController.text.trim(),
        count: int.parse(_countController.text.trim()),
        isCustom: true,
      ),
    );
  }
}
