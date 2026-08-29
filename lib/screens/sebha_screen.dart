import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/sebha_service.dart';
import '../widgets/sebha_counter.dart';

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});

  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen>
    with TickerProviderStateMixin {
  final List<String> azkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله',
  ];

  int count = 0;
  int target = 33;
  String selectedZikr = 'سبحان الله';

  late AnimationController _pageController;
  late AnimationController _tapController;
  late AnimationController _ambientController;
  late AnimationController _completionController;

  late Animation<double> _pageFade;
  late Animation<Offset> _heroSlide;
  late Animation<Offset> _selectorSlide;
  late Animation<Offset> _counterSlide;

  bool _isCompleted = false;

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

    loadSavedData();

    _pageController.forward();
  }

  void loadSavedData() {
    final savedZikr = SebhaService.getZikr();
    final savedCount = SebhaService.getCount();
    final savedTarget = SebhaService.getTarget();

    count = savedCount;
    target = savedTarget;
    selectedZikr = azkar.contains(savedZikr) ? savedZikr : azkar.first;
    _isCompleted = target > 0 && count >= target;
  }

  Future<void> increment() async {
    if (target > 0 && count >= target) {
      return;
    }

    setState(() {
      count++;

      _isCompleted = target > 0 && count >= target;
    });

    if (_isCompleted) {
      _playCompletionAnimation();
    }

    await saveData();
  }

  void _playCompletionAnimation() {
    _completionController.forward(from: 0);
  }

  Future<void> resetCounter() async {
    await _tapController.forward(from: 0);

    if (!mounted) {
      return;
    }

    setState(() {
      count = 0;
      _isCompleted = false;
    });

    await _tapController.reverse();

    _completionController.reset();

    await SebhaService.reset();
  }

  Future<void> changeZikr(String value) async {
    if (selectedZikr == value) {
      return;
    }

    setState(() {
      selectedZikr = value;
      count = 0;
      _isCompleted = false;
    });

    _completionController.reset();

    await saveData();
  }

  Future<void> changeTarget(int value) async {
    if (target == value) {
      return;
    }

    setState(() {
      target = value;
      count = 0;
      _isCompleted = false;
    });

    _completionController.reset();

    await saveData();
  }

  Future<void> saveData() async {
    await SebhaService.save(count: count, target: target, zikr: selectedZikr);
  }

  double get progress {
    if (target <= 0) {
      return 0;
    }

    return (count / target).clamp(0.0, 1.0);
  }

  int get remaining {
    if (target <= 0) {
      return 0;
    }

    return (target - count).clamp(0, target);
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
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                final rotation =
                    math.sin(_ambientController.value * math.pi * 2) * 0.025;

                return Transform.rotate(angle: rotation, child: child);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 20,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'السبحة',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        centerTitle: true,
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
                child: _buildHeroHeader(colors),
              ),
              const SizedBox(height: 18),
              _animatedSection(
                animation: _selectorSlide,
                child: Column(
                  children: [
                    _buildZikrSelector(context, colors),
                    const SizedBox(height: 12),
                    _buildTargetSelector(context, colors),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _animatedSection(
                animation: _counterSlide,
                child: _buildCurrentZikr(colors),
              ),
              const SizedBox(height: 16),
              _animatedSection(
                animation: _counterSlide,
                child: _buildCounterArea(context, colors),
              ),
              const SizedBox(height: 20),
              _animatedSection(
                animation: _counterSlide,
                child: _buildProgress(colors),
              ),
              const SizedBox(height: 16),
              _animatedSection(
                animation: _counterSlide,
                child: _buildTip(colors),
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

  Widget _buildHeroHeader(ColorScheme colors) {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glow = 0.10 + (_ambientController.value * 0.05);

        return Container(
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
                color: colors.primary.withValues(alpha: glow),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اذكر الله يطمئن قلبك',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سبّح واطمئن',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ذكر بسيط • أثر كبير',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            size: 19,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildZikrSelector(BuildContext context, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الذكر',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: selectedZikr,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.primary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.20),
                ),
              ),
            ),
            items: azkar.map((zikr) {
              return DropdownMenuItem<String>(
                value: zikr,
                child: Text(
                  zikr,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                changeZikr(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelector(BuildContext context, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.flag_outlined, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هدف التسبيح',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  target == 33 ? '33 مرة' : '99 مرة',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
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
            selected: {target},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                changeTarget(selection.first);
              }
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentZikr(ColorScheme colors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(selectedZikr),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              'الذكر الحالي',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedZikr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                height: 1.35,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterArea(BuildContext context, ColorScheme colors) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _tapController,
        _ambientController,
        _completionController,
      ]),
      builder: (context, child) {
        final tapScale = 1 - (_tapController.value * 0.035);

        final completionScale = _isCompleted
            ? 1 + (_completionController.value * 0.025)
            : 1.0;

        final glow = 0.04 + (_ambientController.value * 0.035);

        return Transform.scale(
          scale: tapScale * completionScale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(
                    alpha: _isCompleted
                        ? 0.14 + (_completionController.value * 0.10)
                        : glow,
                  ),
                  blurRadius: _isCompleted ? 32 : 20,
                  spreadRadius: _isCompleted ? 2 : 0,
                ),
              ],
            ),
            child: SebhaCounter(
              count: count,
              target: target,
              onTap: increment,
              onReset: resetCounter,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _isCompleted ? 'تم إكمال الهدف ✓' : 'التقدم',
                  key: ValueKey(_isCompleted),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _isCompleted ? colors.primary : colors.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  '$count / $target',
                  key: ValueKey(count),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: colors.primary.withValues(alpha: 0.08),
                  color: colors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _isCompleted
                  ? 'ما شاء الله، تم بحمد الله'
                  : 'متبقي $remaining مرة',
              key: ValueKey(_isCompleted ? 'done' : remaining),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'سيتم حفظ تقدمك تلقائيًا حتى بعد إغلاق التطبيق.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
