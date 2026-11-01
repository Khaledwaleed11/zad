import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../cubit/sebha_cubit.dart';
import '../cubit/sebha_state.dart';
import '../widgets/sebha_app_bar.dart';
import '../widgets/sebha_counter_area.dart';
import '../widgets/sebha_current_zikr.dart';
import '../widgets/sebha_hero_header.dart';
import '../widgets/sebha_progress.dart';
import '../widgets/sebha_target_selector.dart';
import '../widgets/sebha_tip.dart';
import '../widgets/sebha_zikr_selector.dart';

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
      appBar: SebhaAppBar(paper: _paper, gold: _gold, textColor: _textColor),
      body: FadeTransition(
        opacity: _pageFade,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
          child: Column(
            children: [
              _animatedSection(
                animation: _heroSlide,
                child: SebhaHeroHeader(
                  ambientAnimation: _ambientController,
                  gold: _gold,
                  innerPaper: _innerPaper,
                  lightGold: _lightGold,
                  mutedColor: _mutedColor,
                  textColor: _textColor,
                ),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _selectorSlide,
                child: Column(
                  children: [
                    _buildZikrSelector(state),
                    const SizedBox(height: 12),
                    SebhaTargetSelector(
                      target: state.target,
                      paper: _paper,
                      innerPaper: _innerPaper,
                      gold: _gold,
                      lightGold: _lightGold,
                      textColor: _textColor,
                      mutedColor: _mutedColor,
                      onChanged: changeTarget,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _animatedSection(
                animation: _counterSlide,
                child: SebhaCurrentZikr(
                  zikr: state.zikr,
                  innerPaper: _innerPaper,
                  gold: _gold,
                  lightGold: _lightGold,
                  textColor: _textColor,
                  mutedColor: _mutedColor,
                ),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _counterSlide,
                child: SebhaCounterArea(
                  tapAnimation: _tapController,
                  ambientAnimation: _ambientController,
                  completionAnimation: _completionController,
                  isCompleted: state.isCompleted,
                  count: state.count,
                  target: state.target,
                  gold: _gold,
                  onTap: increment,
                  onReset: resetCounter,
                ),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _counterSlide,
                child: SebhaProgress(
                  count: state.count,
                  target: state.target,
                  progress: state.progress,
                  remaining: state.remaining,
                  isCompleted: state.isCompleted,
                  gold: _gold,
                  textColor: _textColor,
                  mutedColor: _mutedColor,
                ),
              ),
              const SizedBox(height: 16),
              _animatedSection(
                animation: _counterSlide,
                child: SebhaTip(gold: _gold, mutedColor: _mutedColor),
              ),
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

  Widget _buildZikrSelector(SebhaState state) {
    final availableAzkar = <String>{...azkar, ...state.customAzkar}.toList();

    final selectedZikr = availableAzkar.contains(state.zikr)
        ? state.zikr
        : availableAzkar.first;

    return SebhaZikrSelector(
      availableAzkar: availableAzkar,
      selectedZikr: selectedZikr,
      paper: _paper,
      innerPaper: _innerPaper,
      gold: _gold,
      lightGold: _lightGold,
      textColor: _textColor,
      mutedColor: _mutedColor,
      onChanged: changeZikr,
    );
  }
}
