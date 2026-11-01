import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../cubit/sebha_cubit.dart';
import '../cubit/sebha_state.dart';
import '../widgets/sebha_counter.dart';

class SebhaScreen extends StatelessWidget {
  const SebhaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SebhaCubit>()..loadSebhaData(),
      child: const _SebhaScreenView(),
    );
  }
}

class _SebhaScreenView extends StatefulWidget {
  const _SebhaScreenView();

  @override
  State<_SebhaScreenView> createState() => _SebhaScreenViewState();
}

class _SebhaScreenViewState extends State<_SebhaScreenView>
    with TickerProviderStateMixin {
  final List<String> azkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله',
  ];

  late AnimationController _pageController;
  late AnimationController _tapController;
  late AnimationController _ambientController;
  late AnimationController _completionController;

  late Animation<double> _pageFade;
  late Animation<Offset> _heroSlide;
  late Animation<Offset> _selectorSlide;
  late Animation<Offset> _counterSlide;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _paper =>
      _isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

  Color get _innerPaper =>
      _isDark ? const Color(0xFF201B13) : const Color(0xFFFFFCF4);

  Color get _gold =>
      _isDark ? const Color(0xFFD6BE83) : const Color(0xFFA88746);

  Color get _lightGold =>
      _isDark ? const Color(0xFF806B43) : const Color(0xFFD6BE83);

  Color get _textColor =>
      _isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

  Color get _mutedColor =>
      _isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pageFade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _heroSlide = Tween<Offset>(begin: const Offset(0, -0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.00, 0.28, curve: Curves.easeOutCubic),
          ),
        );

    _selectorSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.15, 0.48, curve: Curves.easeOutCubic),
          ),
        );

    _counterSlide =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageController,
            curve: const Interval(0.38, 1.00, curve: Curves.easeOutCubic),
          ),
        );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _pageController.forward();
  }

  Future<void> increment() async {
    await context.read<SebhaCubit>().increment();
  }

  void _playCompletionAnimation() {
    _completionController.forward(from: 0);
  }

  Future<void> resetCounter() async {
    await _tapController.forward(from: 0);

    if (!mounted) return;

    await context.read<SebhaCubit>().resetCounter();

    if (!mounted) return;

    await _tapController.reverse();
    _completionController.reset();
  }

  Future<void> changeZikr(String value) async {
    await context.read<SebhaCubit>().changeZikr(value);
    _completionController.reset();
  }

  Future<void> changeTarget(int value) async {
    await context.read<SebhaCubit>().changeTarget(value);
    _completionController.reset();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tapController.dispose();
    _ambientController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SebhaCubit, SebhaState>(
      listener: (context, state) {
        if (state.isCompleted) {
          _playCompletionAnimation();
        }

        if (state.count == 0) {
          _completionController.reset();
        }
      },
      listenWhen: (previous, current) {
        return previous.status == SebhaStatus.success &&
            !previous.isCompleted &&
            current.isCompleted;
      },
      builder: (context, state) {
        return _buildScreen(state);
      },
    );
  }

  Widget _buildScreen(SebhaState state) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconBox(Icons.fingerprint_rounded, size: 36),
            const SizedBox(width: 10),
            Text(
              'السبحة',
              style: TextStyle(
                color: _textColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _pageFade,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
          child: Column(
            children: [
              _animatedSection(
                animation: _heroSlide,
                child: _buildHeroHeader(),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _selectorSlide,
                child: Column(
                  children: [
                    _buildZikrSelector(state),
                    const SizedBox(height: 12),
                    _buildTargetSelector(state),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _animatedSection(
                animation: _counterSlide,
                child: _buildCurrentZikr(state),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _counterSlide,
                child: _buildCounterArea(state),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _counterSlide,
                child: _buildProgress(state),
              ),
              const SizedBox(height: 16),
              _animatedSection(animation: _counterSlide, child: _buildTip()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedSection({
    required Animation<Offset> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: animation,
      child: FadeTransition(opacity: _pageFade, child: child),
    );
  }

  Widget _buildIconBox(IconData icon, {double size = 42}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: _gold, size: size * 0.52),
    );
  }

  Widget _paperCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius + 3),
        border: Border.all(color: _gold.withValues(alpha: 0.75), width: 1),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: _innerPaper,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: _lightGold.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: 0, right: 0, child: _cornerDecoration()),
            Positioned(
              top: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: _cornerDecoration(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi,
                child: _cornerDecoration(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _cornerDecoration() {
    return Icon(
      Icons.auto_awesome_rounded,
      size: 12,
      color: _gold.withValues(alpha: 0.65),
    );
  }

  Widget _buildHeroHeader() {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glow = 0.07 + (_ambientController.value * 0.04);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _gold.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: glow),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: _innerPaper,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: _lightGold.withValues(alpha: 0.55)),
            ),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.12),
              border: Border.all(
                color: _gold.withValues(alpha: 0.65),
                width: 1.3,
              ),
            ),
            child: Icon(Icons.fingerprint_rounded, color: _gold, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اذكر الله يطمئن قلبك',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mutedColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'سبّح واطمئن',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ذكر بسيط • أثر كبير',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _gold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            size: 21,
            color: _gold.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildZikrSelector(SebhaState state) {
    final availableAzkar = <String>{...azkar, ...state.customAzkar}.toList();

    final selectedZikr = availableAzkar.contains(state.zikr)
        ? state.zikr
        : availableAzkar.first;

    return _paperCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            icon: Icons.menu_book_rounded,
            title: 'اختر الذكر',
          ),
          const SizedBox(height: 13),
          InkWell(
            onTap: () => _showZikrPicker(availableAzkar, selectedZikr),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: _paper,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _lightGold.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: _gold,
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedZikr,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _gold,
                    size: 25,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _showZikrPicker(
      List<String> availableAzkar,
      String selectedZikr,
      ) async {
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
            color: _paper,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: _gold.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: _lightGold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Row(
                  children: [
                    _buildIconBox(Icons.menu_book_rounded, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر الذكر',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر الذكر الذي تريد التسبيح به',
                            style: TextStyle(
                              color: _mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: _gold,
                      size: 22,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: _lightGold.withValues(alpha: 0.35),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  itemCount: availableAzkar.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final zikr = availableAzkar[index];
                    final isSelected = zikr == selectedZikr;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext, zikr);
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
                              ? _gold.withValues(alpha: 0.13)
                              : _innerPaper,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? _gold
                                : _lightGold.withValues(alpha: 0.35),
                            width: isSelected ? 1.3 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: _gold,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                zikr,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: _textColor,
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
                                  color: _gold,
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

    if (result != null && result != selectedZikr) {
      await changeZikr(result);
    }
  }
  Widget _buildTargetSelector(SebhaState state) {
    return _paperCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          _buildIconBox(Icons.flag_rounded, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هدف التسبيح',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.target} مرة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 33, label: Text('33')),
              ButtonSegment<int>(value: 99, label: Text('99')),
            ],
            selected: {state.target},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                changeTarget(selection.first);
              }
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? _innerPaper
                    : _gold;
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected) ? _gold : _paper;
              }),
              side: WidgetStateProperty.all(
                BorderSide(color: _gold.withValues(alpha: 0.55)),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _gold),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: _textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentZikr(SebhaState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: _paperCard(
        radius: 21,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
        child: Column(
          children: [
            Text(
              'الذكر الحالي',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _mutedColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              state.zikr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                height: 1.45,
                fontWeight: FontWeight.w900,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 2,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterArea(SebhaState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _tapController,
        _ambientController,
        _completionController,
      ]),
      builder: (context, child) {
        final tapScale = 1 - (_tapController.value * 0.035);

        final completionScale = state.isCompleted
            ? 1 + (_completionController.value * 0.025)
            : 1.0;

        final glow = 0.05 + (_ambientController.value * 0.035);

        return Transform.scale(
          scale: tapScale * completionScale,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: _gold.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(
                    alpha: state.isCompleted
                        ? 0.16 + (_completionController.value * 0.09)
                        : glow,
                  ),
                  blurRadius: state.isCompleted ? 32 : 22,
                  spreadRadius: state.isCompleted ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: SebhaCounter(
                count: state.count,
                target: state.target,
                onTap: increment,
                onReset: resetCounter,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(SebhaState state) {
    return _paperCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                state.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.trending_up_rounded,
                color: _gold,
                size: 18,
              ),
              const SizedBox(width: 7),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  state.isCompleted ? 'تم إكمال الهدف ✓' : 'التقدم',
                  key: ValueKey(state.isCompleted),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: state.isCompleted ? _gold : _textColor,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  '${state.count} / ${state.target}',
                  key: ValueKey(state.count),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: state.progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: _gold.withValues(alpha: 0.13),
                  color: _gold,
                ),
              );
            },
          ),
          const SizedBox(height: 11),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              state.isCompleted
                  ? 'ما شاء الله، تم بحمد الله'
                  : 'متبقي ${state.remaining} مرة',
              key: ValueKey(state.isCompleted ? 'done' : state.remaining),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 20, color: _gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم حفظ تقدمك تلقائيًا حتى بعد إغلاق التطبيق.',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: _mutedColor,
              ),
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: _gold.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
