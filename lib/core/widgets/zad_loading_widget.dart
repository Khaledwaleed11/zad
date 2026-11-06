import 'package:flutter/material.dart';

enum ZadLoadingType { dua, quran }

class ZadLoadingWidget extends StatefulWidget {
  final ZadLoadingType type;

  const ZadLoadingWidget({super.key, required this.type});

  @override
  State<ZadLoadingWidget> createState() => _ZadLoadingWidgetState();
}

class _ZadLoadingWidgetState extends State<ZadLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _progressController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatAnimation;

  static const Color _goldBase = Color(0xFFA88746);
  static const Color _lightGold = Color(0xFFD6BE83);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _gold => _isDark ? _lightGold : _goldBase;

  Color get _paper =>
      _isDark ? const Color(0xFF252017) : const Color(0xFFF7F1DF);

  Color get _innerPaper =>
      _isDark ? const Color(0xFF201B13) : const Color(0xFFFFFCF4);

  Color get _text =>
      _isDark ? const Color(0xFFF2E8D2) : const Color(0xFF493A25);

  Color get _muted =>
      _isDark ? const Color(0xFFC1B18F) : const Color(0xFF786548);

  bool get _isDua => widget.type == ZadLoadingType.dua;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _isDua
        ? Icons.volunteer_activism_rounded
        : Icons.menu_book_rounded;
    final title = _isDua ? 'جاري تجهيز الأدعية' : 'جاري تجهيز اختبار الحفظ';
    final subtitle = _isDua
        ? 'لحظات ونبدأ معًا...'
        : 'نراجع الآيات ونجهز أسئلتك...';

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final availableHeight = constraints.maxHeight;
        final compact = availableHeight.isFinite && availableHeight < 340;
        final horizontalMargin = (availableWidth * 0.06)
            .clamp(12.0, 28.0)
            .toDouble();
        final heroSize = compact ? 88.0 : 112.0;
        final verticalPadding = compact ? 18.0 : 30.0;
        final sectionGap = compact ? 14.0 : 22.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _paper,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: _isDark ? 0.05 : 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 14 : 20,
                  vertical: verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: _innerPaper,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _gold.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: heroSize,
                      height: heroSize,
                      child: _buildAnimatedEmblem(icon, heroSize),
                    ),
                    SizedBox(height: sectionGap),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    _buildShimmerProgress(compact: compact),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedEmblem(IconData icon, double size) {
    final orbitSize = size * 0.92;
    final iconSize = size * 0.31;

    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _pulseAnimation]),
      builder: (context, child) {
        final pulse = _pulseAnimation.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: orbitSize,
              height: orbitSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.035 + (pulse * 0.035)),
                border: Border.all(
                  color: _gold.withValues(alpha: 0.14 + (pulse * 0.12)),
                  width: 1,
                ),
              ),
            ),
            RotationTransition(
              turns: _orbitController,
              child: SizedBox(
                width: orbitSize,
                height: orbitSize,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: _buildOrbitSparkle(size * 0.075),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildOrbitSparkle(size * 0.055),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildOrbitSparkle(size * 0.07),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildOrbitSparkle(size * 0.05),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Transform.scale(
                    scale: 0.94 + (_pulseAnimation.value * 0.08),
                    child: Container(
                      width: size * 0.62,
                      height: size * 0.62,
                      decoration: BoxDecoration(
                        color: _gold.withValues(
                          alpha: 0.10 + (_pulseAnimation.value * 0.06),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.55),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(
                              alpha: 0.08 + (_pulseAnimation.value * 0.10),
                            ),
                            blurRadius: 16.0 + (_pulseAnimation.value * 8.0),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, size: iconSize, color: _gold),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrbitSparkle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: size),
        ],
      ),
    );
  }

  Widget _buildShimmerProgress({required bool compact}) {
    return SizedBox(
      width: compact ? 132 : 150,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: _gold.withValues(alpha: 0.15)),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _progressController.value,
                  alignment: AlignmentDirectional.centerStart,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gold.withValues(alpha: 0.75),
                          _gold,
                          _gold.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
